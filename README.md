# Introduction
This repository contains a reference solution for notifying incoming source data files for Agile Data Engine Notify API (https://docs.agiledataengine.com/docs/notify-api-saas). 

**The repository is provided for reference purposes only and the solution may require modifications to fit your use case. Note that this solution is not part of the Agile Data Engine product. Please use at your own caution.**

**Contents:**
- Terraform templates for deploying required resources in the cloud of your choice (AWS, Azure or GCP)
- Python functions code for the notifier

# Notifier architecture & process
Reference Notifier solution architecture in high level:

![Notifier architecture](architecture/ade_notifier_flow.png)

## Notifying process

1. Source data files are created into cloud storage by an external process (i.e. not Agile Data Engine nor the Notifier).
2. File events are sent to a function in the cloud. Implementation details differ from cloud to cloud.
3. Function will read configuration YAML-files from /data-sources.
    - Based on the configuration, events are added to /queue folder in JSON-format. These event files contain the event data, such as location of the original file.
    - Configuration YAML-file is used to divide events to correct foldering within the queue folder
4. Another cloud function is either scheduled or triggered to continue the notifying process. This function:
    - Processes the queue for new file events
    - Notifies events to ADE Notify API based on the set configuration
    - Logs status and/or error based on the notifying status
    - Moves notified file events to /notified

# Data source configuration
Configure data sources into configuration files in YAML-format. 

See configuration example in [config/example_1.yaml](config/example_1.yaml). These YAML-files can be split into multiple files depending on the requirements.

A table describing each attribute in YAML and supported levels:

| **Attribute**               | **Mandatory** | **Description**                                                                                                                                                                  |
|-----------------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `parameters.max_files_per_manifest` | Yes           | Specifies the maximum number of files that can be included in a single manifest.                                                                                                 |
| `source_systems`             | Yes           | A list of source systems, each representing a data source with its attributes.                                                                                                   |
| `source_systems.ade_source_system` | Yes           | The identifier of the source system, e.g., `ny_tlc` or `digitraffic`.                                                                                                           |
| `source_systems.single_file_manifest` | No            | Indicates whether a single file should be included in the manifest for the source system. Default: `false`.                                                                     |
| `source_systems.fullscanned` | No            | Specifies whether the entire source table is scanned. Can also be defined at the **entity level** (Overrides source system level if defined at entity).                        |
| `source_systems.dag_trigger` | No            | Specifies the name of the DAG trigger for the source system, if applicable.                                                                                                     |
| `source_systems.cron_schedule` | No            | Specifies the cron schedule for running the source system's process, if applicable. **Requires dag_trigger to be defined.**                                                                                            |
| `source_systems.entities`    | Yes           | A list of entities associated with the source system, each representing a table.                                                                                     |
| `entities.ade_source_entity` | Yes           | The identifier of the source entity within ADE, e.g., `yellow_tripdata_bq`.                                                                                              |
| `entities.file_location`     | Yes           | The path to the entity's file location, relative to the root storage path, e.g., `ny_tlc/yellow_tripdata`.                                                                     |
| `entities.format`            | Yes           | The file format of the entity, e.g., `PARQUET`, `CSV`, or `JSON`. Can be defined at both the **source_systems** level and the **entities** level. Entity level takes precedence. |
| `entities.delim`             | No            | Specifies the delimiter used in the entity's file if the format is `CSV`. Examples: `COMMA`, `SEMICOLON`.                                                                       |
| `entities.skiph`             | No            | The number of header rows to skip when processing the file, if applicable.                                                                                                      |
| `entities.compression`       | No            | The compression format used for the file, e.g., `GZIP`.                                                                                                                         |
| `entities.fullscanned`       | No            | Specifies whether the entity is fully scanned. Overrides the `fullscanned` setting at the **source_systems** level if defined at the **entity** level.                         |
| `source_systems.single_file_manifest` | No           | Indicates whether a single file manifest is created for the source system. Default: `false`. Can also be set for each **entity** within `entities`.                            |
| `entities.fullscanned`       | No            | Specifies whether the entity is fully scanned. Overrides the value set at the **source_systems** level if defined.                                                                 |

- **Attributes that can be defined at both the `source_systems` and `entities` levels**. For each, the **entity-level** takes precedence:
  - **`format`**
  - **`delim`**
  - **`skiph`**
  - **`compression`**
  - **`fullscanned`**
  - **`single_file_manifest`**


The YAML-files are translated to configuration format specified in [adenotifier library readme](https://github.com/agile-data-engine/adenotifier). YAML-format is simplification of the configuration.

# Deployable resources
Describing terraform and function code and how to deploy the resources.

## Cloud-specific resources
In /cloud_resources folder, cloud-specific resources are divided to folders by cloud provider.

All resources are written in terraform. 
Cloud-specific documentation can be found from each cloud-specific folder.
Each cloud-specific folder has the following structure:
```
cloud_folder
├── architecture
├── environments
└── terraform
```
README.md in each cloud_folder will explain the deployment process for each cloud environment.

## Common resources
All functions have been written in Python and can be found from /functions folder:
```
functions
├── aws
├── azure
├── common
└── gcp
```

Let's say you would need to deploy to aws, so in that case you can just remove azure and gcp folders from /functions.

# Dependencies
This solution uses the [adenotifier](https://github.com/agile-data-engine/adenotifier) Python library. Please specify a version in requirements.txt to prevent issues with library upgrades.