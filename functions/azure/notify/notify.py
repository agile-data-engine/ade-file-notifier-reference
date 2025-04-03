import azure.functions as func
import logging
import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from shared.azure_handler import (
    AzureFileHandler,
    download_config,
    upload_notifier_status
)
from shared.notifier_common import (
    get_matching_configs,
    manifest_handler,
    dag_trigger_handler
)

def notify(msg: func.QueueMessage):
    """
    Triggered as messages are added to Azure Queue storage.
        
    Args:
        msg (azure.functions.QueueMessage): Azure Queue storage message which triggers the function.

    Returns:
        Event processing status.
    """
    return process_events(msg.get_json())

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
        event_data: Either event data from queue or http call, formatted to JSON object.

    Returns:
        Http responses with jsonify
    """
    try:
        logging.info(f'Notifier was triggered by call:\n{event_data}')

        container_name = os.getenv('container_name')
        config_prefix = os.getenv('config_prefix')

        # Using SecretClient to get secrets from key vault instead of references in app settings for Flex Consumption Plan compatibility
        # https://learn.microsoft.com/en-us/azure/azure-functions/flex-consumption-plan#considerations
        credential = DefaultAzureCredential()
        kv_client = SecretClient(vault_url=os.getenv('key_vault_uri'), credential=credential)
        secrets = {
            "base_url": os.getenv('notify_api_base_url'),
            "api_key": kv_client.get_secret('notify_api_key'),
            "api_key_secret": kv_client.get_secret('notify_api_key_secret')
        }
        ext_api_secrets = {
            "base_url": os.getenv('external_api_base_url'),
            "api_key": kv_client.get_secret('external_api_key'),
            "api_key_secret": kv_client.get_secret('external_api_key_secret')
        }

        config_dict = download_config(container_name, config_prefix)
        notifier_status = []
        if 'calls' not in event_data:
            error_message = """Incorrect event format. Correct format should be: 
                            {'calls': [['<ade_source_system>', '<ade_source_entity>'], ['<ade_source_system1>', '<ade_source_entity1>']]}
                            """
            logging.error(error_message)
            return
    
        for call in event_data['calls']:
            if not isinstance(call, list) or len(call) < 1 or not isinstance(call[0], str):
                logging.error(f"Invalid call format: {call}")
                return

            ade_source_system = call[0]
            
            if len(call) > 1 and call[1]:
                ade_source_entity = call[1]
                file_path_prefix = f"queued/{ade_source_system}/{ade_source_entity}/"
            else:
                ade_source_entity = ""
                file_path_prefix = f"queued/{ade_source_system}/"
            
            matching_configs = get_matching_configs(config_dict, ade_source_system, ade_source_entity)

            try:
                logging.info(f"Processing with input parameters: '{ade_source_system}', '{ade_source_entity}'")
                file_handler = AzureFileHandler(container_name, file_path_prefix)
                json_files_data, file_list = file_handler.download_and_list_files()

                if json_files_data == []:
                    logging.info(f'No events to notify for ade_source_system: {ade_source_system}, ade_source_entity: {ade_source_entity}\nFile list: {file_list}')
                    continue
                entries = [item['full_file_path'] for item in json_files_data]

                for config in matching_configs:
                    folder_path = config['attributes']['folder_path']
                    ade_source_system = config['attributes']['ade_source_system']
                    ade_source_entity = config['attributes']['ade_source_entity']
                    logging.info(f"Processing ade_source_system: {ade_source_system}, ade_source_entity: {ade_source_entity}")

                    manifest_entries = [{"sourceFile": entry} for entry in entries if folder_path in entry]
                    #logging.info(f"Manifest entries amount: {len(manifest_entries)}")

                    max_files_per_manifest = config['attributes']['max_files_per_manifest']
                    manifests = manifest_handler(config, manifest_entries, secrets, max_files_per_manifest)
                    notifier_status.append({"config": config, "notifier_manifests": manifests})

                # After all has been notified, move files to /processed folder
                file_handler.move_files_to_processed(file_list)
                
            except Exception as e:
                logging.error(f"Error occurred: {e}")
                raise
        
        upload_notifier_status(container_name, notifier_status)

        try:
            dag_trigger_handler(notifier_status, ext_api_secrets)
        except Exception as e:
            logging.error(f"Error occurred: {e}")
            raise
        return
    
    except Exception as e:
        logging.error(f"Error occurred: {e}")
        raise