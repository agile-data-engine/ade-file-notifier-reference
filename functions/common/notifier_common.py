from datetime import datetime
from adenotifier import notifier
import logging
import json
import requests

def translate_dict(input_data: object):
    """Translates config YAML (in dict-format) to proper configuration format,
       as specified in adenotifier-library.
       When in config YAML both header-level and item-level values are present,
       the item-level values will take precedence over the header-level values.
       This applies to:
           - format
           - delim
           - compression
           - skiph

    Args:
        input_data (object): YAML configuration file in dict inside a list.

    Returns:
        List of configuration dictionaries.

    """
    output_data = []

    for source in input_data:
        if source is None:
            raise ValueError("Source is None. Expected a dictionary.")
        if 'source_systems' not in source or source['source_systems'] is None:
            print(f"Source system none: {source}")
            raise ValueError("'source_systems' is missing or None in the source dictionary.")
        else:
            max_files_per_manifest = source.get('parameters', {}).get('max_files_per_manifest', None)

            # Iterate over systems
            for system in source['source_systems']:
                # Iterate over entities
                for entity in system['entities']:
                    output_entry = {
                        "id": f"{system['ade_source_system']}/{entity['ade_source_entity']}",
                        "attributes": {
                            "ade_source_system": system['ade_source_system'],
                            "ade_source_entity": entity['ade_source_entity'],
                            "batch_from_file_path_regex": entity.get('batch_from_file_path_regex', system.get('batch_from_file_path_regex', None)),
                            "folder_path": entity.get('file_location', None),
                            "path_replace": entity.get('path_replace', system.get('path_replace', None)),
                            "path_replace_with": entity.get('path_replace_with', system.get('path_replace_with', None)),
                            "single_file_manifest": entity.get('single_file_manifest', system.get('single_file_manifest', None)),
                            "max_files_per_manifest": max_files_per_manifest,
                            "dag_trigger": entity.get('dag_trigger', system.get("dag_trigger", None)),
                            "file_extension": entity.get('file_extension', system.get("file_extension", None)),
                        },
                        "manifest_parameters": {
                            "columns": entity.get('columns', None),
                            "compression": entity.get('compression', system.get('compression', None)),
                            "delim": entity.get('delim', system.get('delim', None) if entity.get('format', system.get('format', None)) == 'CSV' else None),
                            "format": "UNKNOWN" if entity.get('format', system.get('format', None)) == 'PARQUET' else entity.get('format', system.get('format', None)),
                            "fullscanned": entity.get('fullscanned', system.get('fullscanned', None)),
                            "skiph": entity.get('skiph', system.get('skiph', None) if entity.get('format', system.get('format', None)) == 'CSV' else None),
                        }
                    }
                    
                    # Remove None values from attributes and manifest_parameters
                    output_entry['attributes'] = {k: v for k, v in output_entry['attributes'].items() if v is not None}
                    output_entry['manifest_parameters'] = {k: v for k, v in output_entry['manifest_parameters'].items() if v is not None}

                    output_data.append(output_entry)

    return output_data


def identify_sources(file_url: str, config: object):
    """Compares a file url to the data source configuration to find matches.

    Args:
        file_url (str): File url.
        config (object): Data source configuration file as JSON object.

    Returns:
        List of matched sources.

    """

    sources = []
    
    for source in config:
        source_path = source['attributes']['folder_path']
        
        # Optional attribute
        if ('file_extension' in source['attributes']):
            source_extension = source['attributes']['file_extension']
        else:
            source_extension = ""

        file_path = '/'.join(file_url.split('/')[3:])

        if (file_path.startswith(f'{source_path}') and source_extension in file_url):
            sources.append(source)

    return sources

def construct_folder_path(config: dict):
    """Creates filepath according to the specs.
    file_path = ade_source_system/ade_source_entity/YYYY/MM/DD/

    Args:
        config (object): Data source configuration file as dict.

    Returns:
        Filepath

    """

    year, month, day, hour = datetime.now().strftime('%Y %m %d %H').split()
    ade_source_system = config['attributes']['ade_source_system']
    ade_source_entity = config['attributes']['ade_source_entity']

    folder_path = f"{ade_source_system}/{ade_source_entity}/{year}/{month}/{day}/{hour}"

    return folder_path


def get_matching_configs(config_data: object, ade_source_system: str, ade_source_entity: str):
    """
    Get matching config-files.

    Args:
        config_data (object): Configuration data.
        ade_source_system (string)
        ade_source_entity (string)
    Returns:
        matching_configs (object)

    """
    matching_configs = []

    for config in config_data:
        attributes = config.get('attributes', {})
        
        if attributes.get('ade_source_system') == ade_source_system:
            if ade_source_entity == "":
                matching_configs.append(config)
            elif attributes.get('ade_source_entity') == ade_source_entity:
                matching_configs.append(config)

    return matching_configs


def manifest_handler(
        manifest_header: object, 
        manifest_entries: object, 
        secrets: object, 
        max_files_per_manifest: int):
    """
    Handles manifest and posts to Notify API

    Args:
        manifest_header (object): Configuration for the manifest, such as delimiter, skip header etc.
        manifest_entries (object): Manifest entries.
        secrets (object): Secrets for Notify API
        max_files_per_manifest (int): Max files sent per manifest. If given, can be used to split entries to multiple manifests.
    Returns:
        manifests

    """
    manifest_parts = [manifest_entries[i:i + max_files_per_manifest] for i in range(0, len(manifest_entries), max_files_per_manifest)]

    base_url = secrets['base_url']
    api_key = secrets['api_key']
    api_key_secret = secrets['api_key_secret']
    manifests = []

    # Loop manifest parts
    for manifest_part in manifest_parts:
        notify = notifier.add_multiple_entries_to_manifest(manifest_part, manifest_header, base_url, api_key, api_key_secret)
        manifest_id = notify.id

        formatted_timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')
        manifests.append({
            "manifest_id": manifest_id, 
            "entry_amount": len(manifest_part), 
            "entries": manifest_part, 
            "status": "success",
            "notification_time": formatted_timestamp
            })

    return manifests

def dag_trigger_handler(notifier_status: object, secrets: object):
    """
    Handle DAG triggers for notifier.

    Args:
        notifier_status (object): Notifier status object.
        secrets (object): External API secrets containing URL and API-keys.
    Returns:
        dags_to_trigger

    """
    distinct_dags = set()

    for item in notifier_status:
        dag_trigger = item.get("config", {}).get("attributes", {}).get("dag_trigger")
        if dag_trigger:
            distinct_dags.add(dag_trigger)
    
    dags_to_trigger = list(distinct_dags)

    session = requests.Session()
    session.headers.update({"X-API-KEY-ID": secrets['api_key'],
                    "X-API-KEY-SECRET": secrets['api_key_secret'], "Content-Type": "application/json"})

    for dag_name in dags_to_trigger:
        logging.info(f"Triggering dag: {dag_name}")
        dag_run = start_dag_run_v2(session, secrets['base_url'], dag_name)
        logging.info(f"Got response from dag_run: {dag_run}")

    return dags_to_trigger

def start_dag_run_v2(session: requests.Session, base_url: str, dag_id: str):
    """
    Start DAG run.

    Args:
        session (requests.Session): Session to ADE External API.
        base_url (string): URL to ADE External API.
        dag_id (string): DAG name in ADE Runtime environment.
    Returns:
        content
    Raises:
        HTTPError: If the request fails.

    """
    response = session.post(f"{base_url}/dagger/v2/dags/{dag_id}/dag-runs")
    content = response.json() if response.text else {}

    if response.status_code == 401:
        logging.error(f"Unauthorized. Response code {response.status_code}")
        raise requests.exceptions.HTTPError("Unauthorized access. Please check your credentials.")
    elif response.status_code != 201:
        logging.error(f"Unable to start DAG with dag id {dag_id}. Response code {response.status_code}: \n{content}")
        raise requests.exceptions.HTTPError(f"Request failed with status code {response.status_code}")
    return content