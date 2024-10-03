## Reading log files
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