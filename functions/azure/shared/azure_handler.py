import os
import concurrent.futures
import logging
import yaml
import json
import re
from datetime import datetime
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient, ContentSettings
import time
from .notifier_common import (
    translate_dict
)

def download_config(container_name, folder_prefix):
    """
    Downloads configuration files from the Notifier container (Blob Storage).
    
    Args:
        container_name (str): Notifier container name.
        folder_prefix (str): Notifier config-folder.

    Returns:
        dict: The configuration file formatted as JSON.

    Raises:
        ValueError: If no YAML configuration files are found.
    """
    azure_handler = AzureFileHandler(container_name, folder_prefix)
    yaml_files_data = azure_handler.download_and_load_yaml_files()

    if not yaml_files_data:
        error_msg = "YAML files data is empty."
        logging.error(error_msg)
        raise ValueError(error_msg)
    
    config_dict = translate_dict(yaml_files_data)
    return config_dict

def upload_notifier_status(container_name, notifier_status_content):
    """
    Uploads the notifier status as a JSON file to Blob Storage. Status files are partitioned
    by year, month, day, and named with Unix milliseconds.

    Args:
        container_name (str): Notifier container name.
        notifier_status_content (dict): The notifier status in JSON format.

    Returns:
        None
    """
    year, month, day = datetime.now().strftime('%Y %m %d').split()
    timemillis = round(time.time() * 1000)
    status_file_path = f"status/year={year}/month={month}/day={day}/{timemillis}_notifier_status.json"

    if notifier_status_content:
        status_azure_handler = AzureFileHandler(container_name, "status/")
        status_azure_handler.upload_file(status_file_path, json.dumps(notifier_status_content))

    return

class AzureFileHandler:
    def __init__(self, container_name, prefix, max_retries=3, retry_delay=2, max_workers=4):
        """
        Initializes the AzureFileHandler for interacting with Azure Blob Storage.

        Args:
            container_name (str): Azure Blob Storage container name.
            prefix (str): The folder prefix for operations.
            max_retries (int): Maximum number of retries for download/upload operations.
            retry_delay (int): Delay in seconds between retries.
            max_workers (int): Number of concurrent workers for parallel operations.
        """
        account_url = os.getenv('AzureWebJobsStorage__blobServiceUri')
        credential = DefaultAzureCredential()
        self.blob_service_client = BlobServiceClient(account_url, credential)
        self.container_client = self.blob_service_client.get_container_client(container_name)
        self.prefix = prefix
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.max_workers = max_workers

    def list_files_in_folder(self):
        """
        Lists all files in the folder (Azure Blob prefix).

        Returns:
            list: A list of blob names matching the prefix.

        Raises:
            RuntimeError: If an error occurs while listing files.
        """
        try:
            blobs = self.container_client.list_blobs(name_starts_with=self.prefix)
            return [blob.name for blob in blobs]
        except Exception as e:
            logging.error(f"Error listing files with prefix {self.prefix}: {e}")
            raise
        
    def download_file(self, blob_name):
        """
        Downloads and processes a single file, with retry logic.

        Args:
            blob_name (str): The name of the blob to download.

        Returns:
            dict or list: Parsed file content (JSON or YAML).

        Raises:
            RuntimeError: If file download or processing fails after max retries.
        """
        blob_client = self.container_client.get_blob_client(blob_name)
        
        for attempt in range(self.max_retries):
            try:
                file_content_str = blob_client.download_blob().readall().decode('utf-8')
                
                if blob_name.endswith('.json'):
                    return json.loads(file_content_str)
                elif blob_name.endswith(('.yaml', '.yml')):
                    return yaml.safe_load(file_content_str)
                else:
                    logging.info(f"Unsupported file type for {blob_name}. Skipping.")
                    return None
            except Exception as e:
                logging.error(f"Error downloading or processing file {blob_name} (attempt {attempt + 1}): {e}")
                time.sleep(self.retry_delay)
        
        # After exceeding max_retries
        error_msg = f"Failed to download or process file {blob_name} after {self.max_retries} attempts."
        logging.error(error_msg)
        raise RuntimeError(error_msg)

    def download_and_load_yaml_files(self):
        """
        Downloads YAML configuration files concurrently.

        Returns:
            list: A list of parsed YAML data (dict or list).

        Raises:
            RuntimeError: If an error occurs while downloading or processing YAML files.
        """
        blob_names = self.list_files_in_folder()
        yaml_files = [name for name in blob_names if name.endswith(('.yaml', '.yml'))]
        
        if not yaml_files:
            logging.info(f"No YAML files found in container with prefix {self.prefix}.")
            return []
        
        file_data = []
        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.download_file, blob_name): blob_name for blob_name in yaml_files}
            for future in concurrent.futures.as_completed(futures):
                try:
                    result = future.result()
                    if result:
                        file_data.append(result)
                except Exception as e:
                    logging.error(f"Error processing YAML file: {e}")
                    raise
        
        return file_data
    
    def download_and_list_files(self):
        """
        Downloads JSON notification files concurrently.

        Returns:
            tuple: A tuple containing a list of file data and a list of file names.

        Raises:
            RuntimeError: If an error occurs while downloading or processing notification files.
        """
        blob_names = self.list_files_in_folder()
        
        file_data = []
        file_list = [name for name in blob_names if name.endswith('.json')]

        if file_list == []:
            logging.info(f"No notification files found in container with prefix {self.prefix}.")
            return [], []
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.download_file, blob_name): blob_name for blob_name in file_list}
            
            for future in concurrent.futures.as_completed(futures):
                try:
                    result = future.result()
                    if result:
                        file_data.append(result)
                except Exception as e:
                    logging.error(f"Error processing file: {e}")
                    raise
        
        return file_data, file_list
    
    def move_file(self, file_path):
        """
        Moves a single file from the 'queued' folder to the 'processed' folder.

        Args:
            file_path (str): The path of the file to be moved.

        Raises:
            RuntimeError: If an error occurs while moving the file.
        """
        try:
            # Construct the destination path in the 'processed' folder with the current time
            file_path_parts = file_path.split("/")
            prefix = "/".join(file_path_parts[:3]) # E.g. queued/system/entity
            filename = file_path_parts[-1]  # Extracted file name
            current_time = datetime.now().strftime("%Y/%m/%d/%H") # yyyy/mm/dd/hh
            
            new_path = f"{prefix}/{current_time}/{filename}".replace("queued", "processed", 1)

            # Get the blob object for the current file
            blob_client = self.container_client.get_blob_client(file_path)
            new_blob_client = self.container_client.get_blob_client(new_path)

            # Copy the file to the 'processed' folder
            new_blob_client.start_copy_from_url(blob_client.url)

            # If the copy is successful, delete the original file
            blob_client.delete_blob()

        except Exception as e:
            logging.error(f"Error moving file {file_path} to processed: {e}")
            raise

    def move_files_to_processed(self, file_paths):
        """
        Moves multiple files from the 'queued' folder to the 'processed' folder concurrently.

        Args:
            file_paths (list): A list of file paths to be moved.

        Raises:
            RuntimeError: If an error occurs while moving any of the files.
        """

        # Use ThreadPoolExecutor to execute file moves in parallel
        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            futures = {executor.submit(self.move_file, file_path): file_path for file_path in file_paths}
            
            for future in concurrent.futures.as_completed(futures):
                file_path = futures[future]
                try:
                    future.result()  # This will raise any exceptions that occurred in the thread
                except Exception as e:
                    logging.error(f"Error processing {file_path}: {e}")
                    raise


    def upload_file(self, file_path, data, blob_content_type='application/json'):
        """
        Uploads a file to the Azure Blob Storage container with retry logic.

        Args:
            file_path (str): The path where the file should be uploaded in Azure.
            data (str or dict): The data to be uploaded. It can be a string or a dictionary.
            blob_content_type (str): The MIME type of the uploaded file.

        Returns:
            bool: True if the upload succeeds.

        Raises:
            RuntimeError: If the upload fails after max retries.
        """
        blob_client = self.container_client.get_blob_client(file_path)

        for attempt in range(self.max_retries):
            try:
                result = blob_client.upload_blob(data=data, blob_type="BlockBlob", overwrite=True, content_settings=ContentSettings(content_type=blob_content_type), validate_content=True)
                logging.info(f"Uploaded file to Azure Blob Storage: {file_path}\nResult: {result}")
                return True

            except Exception as e:
                logging.error(f"Failed to upload {file_path} to Azure (attempt {attempt + 1}): {e}")
                time.sleep(self.retry_delay)

        # After exceeding max_retries
        error_msg = f"Failed to upload file {file_path} after {self.max_retries} attempts."
        logging.error(error_msg)
        raise RuntimeError(error_msg)