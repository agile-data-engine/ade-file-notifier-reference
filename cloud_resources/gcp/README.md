## Reading log files

### Creating external table to BigQuery

Status files can be queried with BigQuery External tables as well.

```SQL
CREATE EXTERNAL TABLE file_notifier.raw_status_files (status_content string)
  OPTIONS (
    format ="CSV",
    field_delimiter = '\x10', quote = '',
    uris = ['gs://reference-notifier-dev/status/*.json']
    );

CREATE OR REPLACE VIEW file_notifier.ade_notifier_status AS
WITH json_data AS (
  SELECT
    JSON_QUERY_ARRAY(PARSE_JSON(status_content)) AS json_content,
    _FILE_NAME as status_file_name
  FROM file_notifier.test
)
SELECT
    JSON_VALUE(json_record.config.id) AS config_id,
    JSON_VALUE(json_record.config.attributes.ade_source_entity) AS ade_source_entity,
    JSON_VALUE(json_record.config.attributes.ade_source_system) AS ade_source_system,
    JSON_VALUE(json_record.config.attributes.folder_path) AS folder_path,
    JSON_VALUE(json_record.config.attributes.max_files_per_manifest) AS max_files_per_manifest,
    JSON_VALUE(json_record.config.attributes.single_file_manifest) AS single_file_manifest,
    JSON_VALUE(json_record.config.manifest_parameters.format) AS manifest_format,
    JSON_VALUE(json_record.config.manifest_parameters.fullscanned) AS manifest_fullscanned,
    JSON_VALUE(json_record.config.manifest_parameters.compression) AS manifest_compression,
    JSON_VALUE(json_record.config.manifest_parameters.delim) AS manifest_delim,
    JSON_VALUE(json_record.config.manifest_parameters.skiph) AS manifest_skiph,
    JSON_VALUE(notifier.manifest_id) AS notifier_manifest_id,
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%E6S', JSON_VALUE(notifier.notification_time)) AS notification_time,
    JSON_VALUE(entry.sourceFile) AS source_file,
    status_file_name
FROM
  json_data,
  UNNEST(json_content) AS json_record,
  UNNEST(json_query_array(json_record.notifier_manifests)) as notifier,
  UNNEST(json_query_array(notifier.entries)) as entry;


SELECT
  count(source_file) as file_amount_notified,
  ade_source_entity,
  ade_source_system,
  cast(notification_time as date) as notification_date
FROM file_notifier.ade_notifier_status
GROUP BY ALL
ORDER BY 1 DESC;
```

### Reading locally using DuckDB
It is efficient to read log-files using DuckDB.
- https://duckdb.org/docs/guides/network_cloud_storage/gcs_import.html
- https://console.cloud.google.com/storage/settings;tab=interoperability

```SQL
INSTALL httpfs;
LOAD httpfs;

CREATE SECRET (
      TYPE GCS,
      KEY_ID 'input-hmac-key-id',
      SECRET 'input-hmac-secret'
);

select 
    config.id, 
    config.attributes.ade_source_system, 
    config.attributes.ade_source_entity, 
    unnest(notifier_manifests, recursive:=true),
    filename as log_filename
from read_json('gs://<replace_with_your_bucket>/status/2024/*/*/*.json', filename = true);
```