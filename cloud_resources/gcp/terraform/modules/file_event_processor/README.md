<!-- BEGIN_TF_DOCS -->


## About

This module generates File Event Processor Cloud Function.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.18 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudfunctions2_function.file_foldering_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_storage_bucket.notifier_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.bucket_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_binding.object_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_binding.object_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_object.datasource_files](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.function_object](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [archive_file.function_archive](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_available_cpu"></a> [available\_cpu](#input\_available\_cpu) | Available CPU for the Cloud function. | `string` | n/a | yes |
| <a name="input_config_prefix"></a> [config\_prefix](#input\_config\_prefix) | Folder prefix in Google Cloud storage to fetch configurations. | `string` | `"data-sources/"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_file_event_pubsub_topic_id"></a> [file\_event\_pubsub\_topic\_id](#input\_file\_event\_pubsub\_topic\_id) | Pub/Sub topic id of the file events. | `string` | n/a | yes |
| <a name="input_file_url_prefix"></a> [file\_url\_prefix](#input\_file\_url\_prefix) | Prefix to be used for files. | `string` | `"gs://"` | no |
| <a name="input_function_folder"></a> [function\_folder](#input\_function\_folder) | Folder where functions can be found | `string` | `"functions"` | no |
| <a name="input_max_instance_request_concurrency"></a> [max\_instance\_request\_concurrency](#input\_max\_instance\_request\_concurrency) | Max instance request concurrency for the Cloud function. | `number` | n/a | yes |
| <a name="input_max_instances_preprocessor"></a> [max\_instances\_preprocessor](#input\_max\_instances\_preprocessor) | Max instances to be used for Cloud function. | `number` | n/a | yes |
| <a name="input_notifier_pubsub_topic_id"></a> [notifier\_pubsub\_topic\_id](#input\_notifier\_pubsub\_topic\_id) | Pub/Sub topic id of the file notifier. This is used if single file manifesting is used. | `string` | n/a | yes |
| <a name="input_notifier_service_account"></a> [notifier\_service\_account](#input\_notifier\_service\_account) | GCP service account used for the notifier | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |
| <a name="input_source_data_bucket"></a> [source\_data\_bucket](#input\_source\_data\_bucket) | Bucket for source data | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notifier_bucket_name"></a> [notifier\_bucket\_name](#output\_notifier\_bucket\_name) | Notifier bucket name |
| <a name="output_notifier_bucket_source_code_object"></a> [notifier\_bucket\_source\_code\_object](#output\_notifier\_bucket\_source\_code\_object) | Source code object for functions in notifier bucket |

<!-- END_TF_DOCS -->