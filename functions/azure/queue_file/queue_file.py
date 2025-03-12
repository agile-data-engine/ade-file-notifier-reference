import azure.functions as func
import logging
import os
import json
import base64
from azure.storage.queue import QueueClient
from azure.identity import DefaultAzureCredential
from shared.azure_handler import (
    AzureFileHandler,
    download_config
)
from shared.notifier_common import (
    identify_sources,
    construct_folder_path
)

def queue_file(msg: func.QueueMessage):
    """Triggered as messages are added to Azure Queue storage.
    Gets configuration, identifies data source, adds file to queued folder if the source is identified.
        
    Args:
        msg (azure.functions.QueueMessage): Azure Queue storage message which triggers the function.

    Returns:
        None.
    """

    try:
        event_data = msg.get_json()
        container_name = os.getenv('container_name')
        config_prefix = os.getenv('config_prefix')
        config_dict = download_config(container_name, config_prefix)

        # Handling different versions of event schemas
        blob_url = event_data['data'].get('blobUrl', event_data['data'].get('url'))
        if not blob_url:
            raise KeyError("Neither 'blobUrl' nor 'url' found in event data")
        
        sources = identify_sources(blob_url, config_dict)

        if (sources == [] or not sources):
            logging.info(f'Source not identified for url: {blob_url}')
            return

        for source in sources:
            logging.info(f"Processing source: {source['id']}")
            folder_path = construct_folder_path(source)
            filename = blob_url.split('/')[-1]

            # Construct the full Blob path for the file
            file_path = f"queued/{folder_path}/{filename}.json"
            file_data = json.dumps({"full_file_path": blob_url, "original_event": event_data})

            azure_handler = AzureFileHandler(container_name, "queued/")
            upload_result = azure_handler.upload_file(file_path, file_data)

            if upload_result:
                logging.info(f"Successfully queued file: {blob_url}")

                # If single file manifest option is True, notification will be done right away
                # this is done by sending data to queue, which invokes the notification process
                if source['attributes'].get('single_file_manifest', False):
                    logging.info("Single_file_manifest set as true, triggering notification.")
                    handle_single_file_manifest(source)
            else:
                logging.error(f"Failed to queue file: {blob_url}")
                return
        return
    except Exception as e:
        logging.error(f"Error processing event: {e}")
        logging.error(f"Event: {event_data}")
        raise

def handle_single_file_manifest(source):
    """
    Sends trigger message to notify queue when 'single_file_manifest' is True.
    
    Args:
        source: The source dictionary containing attributes.
    
    Raises:
        ValueError: If required attributes are missing or empty.

    Returns:
        None
    """
    
    # Validate required attributes
    source_system = source['attributes'].get('ade_source_system')
    source_entity = source['attributes'].get('ade_source_entity')

    if not source_system or not source_entity:
        logging.error("Required attributes 'ade_source_system' or 'ade_source_entity' are missing or empty.")
        raise ValueError("Both 'ade_source_system' and 'ade_source_entity' must be provided and non-empty.")
    
    # Construct the message
    message_data = {
        "calls": [[source_system, source_entity]]
    }
    message_json = json.dumps(message_data)
    message_base64 = base64.b64encode(message_json.encode('utf-8')).decode('utf-8')
    queue_url = os.getenv('AzureWebJobsStorage__queueServiceUri')
    queue_name = os.getenv('notify_queue')

    try:
        # Using managed identity
        credential = DefaultAzureCredential()
        queue_client = QueueClient(queue_url, queue_name=queue_name, credential=credential)

        queue_client.send_message(message_base64)
        logging.info(f"Trigger message added to queue: {message_json}")

    except Exception as e:
        logging.error(f"Error adding trigger message to queue: {e}")
        logging.error(f"Message: {message_json}")
        raise