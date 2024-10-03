import concurrent.futures
import logging
import yaml
import json
from google.cloud import storage
import time


class GCPFileHandler:
    def __init__(self, bucket_name, prefix, max_retries=3, retry_delay=2):
        self.client = storage.Client()
        self.bucket = self.client.bucket(bucket_name)
        self.prefix = prefix
        self.max_retries = max_retries
        self.retry_delay = retry_delay

    def list_files_in_folder(self):
        """
        List all files in the folder (GCS bucket prefix) with a limit.
        """
        try:
            blobs = self.bucket.list_blobs(prefix=self.prefix)
            return [blob.name for blob in blobs]
        except Exception as e:
            logging.error(f"Error listing files with prefix {self.prefix}: {e}")
            return []

    def download_and_load_yaml_files(self):
        """
        Download files concurrently, load their content into Python dictionaries.
        """
        blob_names = self.list_files_in_folder()

        if not blob_names:
            logging.info(f"No files found in bucket with prefix {self.prefix}.")
            return []

        try:
            file_data = []
            for blob_name in blob_names:
                blob = self.bucket.blob(blob_name)
                
                if blob_name.endswith(('.yaml', '.yml')):
                    try:
                        # Download blob content directly as string
                        yaml_content_str = blob.download_as_text()

                        # Parse the YAML content
                        yaml_content = yaml.safe_load(yaml_content_str)
                        if yaml_content:
                            file_data.append(yaml_content)
                        else:
                            logging.warning(f"YAML file {blob_name} is empty.")
                    except Exception as e:
                        logging.error(f"Error processing YAML file {blob_name}: {e}")
            if not file_data:
                logging.warning("No valid data loaded.")
            return file_data

        except Exception as e:
            logging.error(f"Error during file download or processing: {e}")
            return []
        

    def download_file(self, blob_name):
        """
        Download and process a single file, with retry logic.
        """
        blob = self.bucket.blob(blob_name)

        for attempt in range(self.max_retries):
            try:
                # Process YAML files
                if blob_name.endswith('.json'):
                    json_content_str = blob.download_as_text()
                    json_content = json.loads(json_content_str)
                    if json_content:
                        return json_content
                    else:
                        logging.warning(f"JSON file {blob_name} is empty.")
                        return None

                # If file type is not supported, skip
                else:
                    logging.info(f"Unsupported file type for {blob_name}. Skipping.")
                    return None

            except Exception as e:
                logging.error(f"Error downloading or processing file {blob_name} (attempt {attempt + 1}): {e}")
                time.sleep(self.retry_delay)  # Delay before retry
        return None

    def download_and_list_files(self):
        """
        Download and load files concurrently.
        """
        blob_names = self.list_files_in_folder()

        if not blob_names:
            logging.info(f"No files found in bucket with prefix {self.prefix}.")
            return [], []

        file_data = []
        max_workers = 8

        # Use ThreadPoolExecutor for parallel file downloads
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
            # Submit all download tasks and collect futures
            futures = {executor.submit(self.download_file, blob_name): blob_name for blob_name in blob_names}

            # Process results as they are completed
            for future in concurrent.futures.as_completed(futures):
                try:
                    result = future.result()
                    if result:  # Add only non-empty results
                        file_data.append(result)
                except Exception as e:
                    logging.error(f"Error processing file: {e}")

        if not file_data:
            logging.warning("No valid data loaded.")
        
        file_list = [name for name in blob_names if name.endswith('.json')]
        return file_data, file_list
    
    def move_file(self, file_path):
        """
        Move a single file from the 'queued' folder to the 'processed' folder.
        
        Args:
            file_path (str): Path of the file to be moved.
        """
        try:
            # Construct the destination path in the 'processed' folder
            new_path = file_path.replace("queued", "processed", 1)
            
            # Get the blob object for the current file
            blob = self.bucket.blob(file_path)
            
            # Copy the file to the 'processed' folder
            new_blob = self.bucket.copy_blob(blob, self.bucket, new_path)
            
            # If the copy is successful, delete the original file
            if new_blob.exists():
                blob.delete()
            else:
                logging.error(f"Failed to copy {file_path} to {new_path}")

        except Exception as e:
            logging.error(f"Error moving file {file_path} to processed: {e}")
            raise e

    def move_files_to_processed(self, file_paths):
        """
        Move files from the 'queued' folder to the 'processed' folder in parallel.
        
        Args:
            file_paths (list): List of file paths to be moved.
        """
        max_workers = 8  # You can adjust the number of threads based on your needs

        # Use ThreadPoolExecutor to execute file moves in parallel
        with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(self.move_file, file_path): file_path for file_path in file_paths}
            
            # Optionally, you can process results as they complete
            for future in concurrent.futures.as_completed(futures):
                file_path = futures[future]
                try:
                    future.result()  # This will raise any exceptions that occurred in the thread
                except Exception as e:
                    logging.error(f"Error processing {file_path}: {e}")


    def upload_file(self, file_path, data, content_type='application/json'):
        """
        Upload a file to the GCS bucket with retry logic.
        
        Args:
            file_path (str): The path where the file should be uploaded in GCS.
            data (str or dict): The data to be uploaded. It can be a string or a dictionary.
            content_type (str): The MIME type of the uploaded file.
            
        Returns:
            bool: True if upload succeeds, False otherwise.
        """
        blob = self.bucket.blob(file_path)

        for attempt in range(self.max_retries):
            try:
                blob.upload_from_string(data=data, content_type=content_type)
                logging.info(f"Uploaded file to GCS: {file_path}")
                return True

            except Exception as e:
                logging.error(f"Failed to upload {file_path} to GCS (attempt {attempt + 1}): {e}")
                time.sleep(self.retry_delay)  # Delay before retry

        logging.error(f"Exceeded max retries. Could not upload {file_path}.")
        return False