from datetime import datetime
from adenotifier import notifier
import logging

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

            for system in source['source_systems']:
                # Extract parameters from the source system
                system_params = {
                    "compression": system.get('compression', None),
                    "delim": system.get('delim', None),
                    "format": system.get('format', None),
                    "fullscanned": system.get('fullscanned', None),
                    "skiph": system.get('skiph', None)
                }
                
                if system_params.get("format") == "PARQUET":
                    system_params["format"] = "UNKNOWN"

                # Iterate over entities
                for entity in system['entities']:
                    output_entry = {
                        "id": f"{system['ade_source_system']}/{entity['ade_source_entity']}",
                        "attributes": {
                            "ade_source_system": system['ade_source_system'],
                            "ade_source_entity": entity['ade_source_entity'],
                            "batch_from_file_path_regex": system.get('batch_from_file_path_regex', None),
                            "folder_path": entity.get('file_location', None),
                            "path_replace": system.get('path_replace', None),
                            "path_replace_with": system.get('path_replace_with', None),
                            "single_file_manifest": system.get('single_file_manifest', None),
                            "max_files_in_manifest": max_files_per_manifest
                        },
                        "manifest_parameters": {
                            "columns": entity.get('columns', None),
                            "compression": entity.get('compression', system_params['compression']),
                            "delim": entity.get('delim', system_params['delim']),
                            "format": "UNKNOWN" if entity.get('format', system_params['format']) == 'PARQUET' else entity.get('format', system_params['format']),
                            "fullscanned": system_params['fullscanned'],
                            "skiph": entity.get('skiph', system_params['skiph']),
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

        if (source_path in file_url and source_extension in file_url):
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


def get_matching_configs(config_data, ade_source_system, ade_source_entity):
    """
    
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


def manifest_handler(manifest_header, manifest_entries, secrets, max_files_in_manifest):
    manifest_parts = [manifest_entries[i:i + max_files_in_manifest] for i in range(0, len(manifest_entries), max_files_in_manifest)]

    base_url = secrets['base_url']
    api_key = secrets['api_key']
    api_key_secret = secrets['api_key_secret']
    manifests = []

    # Loop manifest parts
    for manifest_part in manifest_parts:
        notify = notifier.add_multiple_entries_to_manifest(manifest_part, manifest_header, base_url, api_key, api_key_secret)
        manifest_id = notify.id

        formatted_timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S:%f')
        manifests.append({
            "manifest_id": manifest_id, 
            "entry_amount": len(manifest_part), 
            "entries": manifest_part, 
            "status": "success",
            "notification_time": formatted_timestamp
            })

    return manifests
