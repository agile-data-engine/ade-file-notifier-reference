import functions_framework
import json
import base64
import logging
import os
import google.cloud.logging
from datetime import datetime
import time
import re
from gcp_handler import GCPFileHandler
from common.notifier_common import (
    translate_dict,
    identify_sources,
    construct_folder_path,
    get_matching_configs,
    manifest_handler,
    dag_trigger_handler
)
from flask import jsonify

client = google.cloud.logging.Client()
client.setup_logging()

def download_config(bucket_name, folder_prefix):
    """
    Downloads config-file from Notifier-bucket.
        
    Args:
        bucket_name: notifier bucket name.
        folder_prefix: Notifier config-folder.

    Returns:
        config_dict: config-file formatted to JSON-format
    """
    gcp_handler = GCPFileHandler(bucket_name, folder_prefix)

    yaml_files_data = gcp_handler.download_and_load_yaml_files()

    if yaml_files_data == []:
        logging.error("YAML files data empty")
        return
    
    config_dict = translate_dict(yaml_files_data)

    return config_dict

def upload_notifier_status(bucket_name, notifier_status_content):
    """
    Uploads notifier status as JSON file to notifier bucket.
    Status files are partitioned by year, month, day.
    Status files are named with unix milliseconds in the name.
        
    Args:
        bucket_name: notifier bucket name
        notifier_status_content: Notifier status in JSON-format.

    Returns:
        None.
    """
    year, month, day = datetime.now().strftime('%Y %m %d').split()
    timemillis = round(time.time() * 1000)
    status_file_path = f"status/{year}/{month}/{day}/{timemillis}_notifier_status.json"

    if notifier_status_content != []:
        status_gcp_handler = GCPFileHandler(bucket_name, "status/")
        upload_result = status_gcp_handler.upload_file(status_file_path, json.dumps(notifier_status_content))
    else:
        return

    if upload_result:
        logging.info(f"Notifier status successfully uploaded")
    else:
        logging.error(f"Failed to upload {status_file_path} to GCS.")
        return

@functions_framework.cloud_event
def file_foldering(cloud_event: object) -> None:
    """Triggered by a cloud event.
    Gets configuration, identifies data source, adds file to a manifest if source is identified.
        
    Args:
        cloud_event (functions_framework.cloud_event): Google cloud event which triggers the function.

    Returns:
        None.

    """
    try:
        event_data = json.loads(base64.b64decode(cloud_event.data['message']['data']).decode())
        bucket_name = os.environ['NOTIFIER_BUCKET']
        config_prefix = os.environ['CONFIG_PREFIX']

        config_dict = download_config(bucket_name, config_prefix)
        event_url = f"{os.environ['FILE_URL_PREFIX']}{event_data['bucket']}/{event_data['name']}"

        # Validate that there is file prefix in the event. 
        # Google Cloud can make event from manual folder creation.
        pattern = r'\.[a-zA-Z0-9]+$'
        if re.search(pattern, event_url) is None:
            return
        sources = identify_sources(event_url, config_dict)

        if (sources == []):
            logging.info(f'Source not identified for url: {event_url}')
            return
        
        if not sources:
            logging.info(f'Source not identified for url: {event_url}')
            return

        #storage_client = storage.Client()
        for source in sources:
            logging.info(f"Processing source: {source['id']}")
            folder_path = construct_folder_path(source)
            full_file_path = event_data['name']
            filename = full_file_path.split('/')[-1]


            # Construct the full GCS path for the file
            file_path = f"queued/{folder_path}/{filename}.json"
            filedata = json.dumps({"full_file_path": event_url, "original_event": event_data})

            gcp_handler = GCPFileHandler(bucket_name, "queued/")
            upload_result = gcp_handler.upload_file(file_path, filedata)

            if upload_result:
                logging.info(f"Uploaded file to GCS: {file_path}")
            else:
                logging.error(f"Failed to upload {file_path} to GCS.")
                return
    except Exception as e:
        logging.error(f"Error processing cloud event: {e}")
        return



@functions_framework.cloud_event
def add_to_manifest(cloud_event: object) -> None:
    """
    Event incoming from Pub/Sub.
    Can be scheduled with Cloud Scheduler.

    Args:
        cloud_event (functions_framework.cloud_event): Google cloud event which triggers the function.

    Returns:
        Event processing status.
    """
    event_data = json.loads(base64.b64decode(cloud_event.data['message']['data']).decode())
    return process_events(event_data)


@functions_framework.http
def add_to_manifest_http(request):
    """
    Http request can be sent directly from Cloud function or from BigQuery remote function.

    Args:
        request (functions_framework.http): Http event.

    Returns:
        Event processing status.
    """
    event_data = request.get_json()
    return process_events(event_data)


def process_events(event_data: object):
    """
    The calls block:
    {
        "calls": [
            ["<ade_source_system>", "<ade_source_entity>"], 
            ["<ade_source_system1>", "<ade_source_entity1>"]
            ]
    }
    Where ade_source_entity is optional parameter.

    Event format example:
    {
        "calls": [
            ["digitraffic", "metadata_vessels_bq"],
            ["digitraffic", "locations_latest_bq"],
            ["system", ""]
        ]
    }

    Args:
        event_data: Either event data from Pub/Sub or http call, formatted to JSON object.

    Returns:
        Http responses with jsonify
    """
    try:
        logging.info(f'Cloud Function was triggered by event:\n{event_data}')
        bucket_name = os.environ['NOTIFIER_BUCKET']
        config_prefix = os.environ['CONFIG_PREFIX']
        secrets = json.loads(os.environ['NOTIFY_API_SECRET_ID'])
        ext_api_secrets = json.loads(os.environ['EXTERNAL_API_SECRET_ID'])

        config_dict = download_config(bucket_name, config_prefix)
        notifier_status = []

        if 'calls' not in event_data:
            error_message = """Incorrect event format. Correct format should be: 
                            {'calls': [['<ade_source_system>', '<ade_source_entity>'], ['<ade_source_system1>', '<ade_source_entity1>']]}
                            """
            logging.error(error_message)
            return jsonify({"errorMessage": error_message}), 400
    
        for call in event_data['calls']:
            if not isinstance(call, list) or len(call) < 1 or not isinstance(call[0], str):
                logging.error(f"Invalid call format: {call}")
                return jsonify({"errorMessage": "Invalid call format."}), 400

            
            ade_source_system = call[0]
            ade_source_entity = call[1] if len(call) > 1 and call[1] else ""
            file_path_prefix = f"queued/{ade_source_system}/{ade_source_entity}"
            matching_configs = get_matching_configs(config_dict, ade_source_system, ade_source_entity)

            try:
                logging.info(f"Processing with input parameters: '{ade_source_system}', '{ade_source_entity}'")
                gcp_handler = GCPFileHandler(bucket_name, file_path_prefix)
                json_files_data, file_list = gcp_handler.download_and_list_files()

                if not json_files_data or not isinstance(json_files_data, list):
                    logging.info(f'No events to notify for ade_source_system: {ade_source_system}, ade_source_entity: {ade_source_entity}')
                    continue
                entries = [item['full_file_path'] for item in json_files_data if 'full_file_path' in item]

                if not entries:
                    logging.warning("No valid entries.")
                    continue
                for config in matching_configs:
                    folder_path = config['attributes']['folder_path']
                    ade_source_system = config['attributes']['ade_source_system']
                    ade_source_entity = config['attributes']['ade_source_entity']
                    logging.info(f"Processing ade_source_system: {ade_source_system}, ade_source_entity: {ade_source_entity}")

                    manifest_entries = [{"sourceFile": entry} for entry in entries if folder_path in entry]
                    #logging.info(f"Manifest entries amount: {len(manifest_entries)}")

                    max_files_per_manifest = config['attributes']['max_files_in_manifest']
                    manifests = manifest_handler(config, manifest_entries, secrets, max_files_per_manifest)
                    notifier_status.append({"config": config, "notifier_manifests": manifests})

                # After all has been notified, move files to /processed folder
                gcp_handler.move_files_to_processed(file_list)
                
            except Exception as e:
                logging.error(f"Error occurred: {e}")
                return jsonify({"errorMessage": str(e)}), 400
        
        upload_notifier_status(bucket_name, notifier_status)

        try:
            dag_trigger_handler(notifier_status, ext_api_secrets)
        except Exception as e:
            logging.error(f"Error occurred: {e}")
            return jsonify({"errorMessage": str(e)}), 400

        return jsonify( { "replies" :  [{"status": "OK", "notifier_status": notifier_status}]} ), 200
    
    except Exception as e:
        logging.error(f"Error processing cloud event: {e}")
        return jsonify({"errorMessage": str(e)}), 400