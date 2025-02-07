<!-- BEGIN_TF_DOCS -->


## About

This module generates File Notifier Cloud function.
Also schedules are generated, if those are given in the configuration files.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.18 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_scheduler_job.cloud_scheduler_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job) | resource |
| [google_cloudfunctions2_function.add_to_manifest_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_cloudfunctions2_function.add_to_manifest_function_http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_available_cpu"></a> [available\_cpu](#input\_available\_cpu) | n/a | `string` | n/a | yes |
| <a name="input_config_prefix"></a> [config\_prefix](#input\_config\_prefix) | Folder prefix in Google Cloud storage to fetch configurations. | `string` | `"data-sources/"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_external_api_secret_id"></a> [external\_api\_secret\_id](#input\_external\_api\_secret\_id) | n/a | `string` | n/a | yes |
| <a name="input_file_url_prefix"></a> [file\_url\_prefix](#input\_file\_url\_prefix) | Prefix to be used for files. | `string` | `"gs://"` | no |
| <a name="input_function_memory"></a> [function\_memory](#input\_function\_memory) | n/a | `string` | n/a | yes |
| <a name="input_function_source_code_object"></a> [function\_source\_code\_object](#input\_function\_source\_code\_object) | Function source code object | `string` | n/a | yes |
| <a name="input_function_timeout"></a> [function\_timeout](#input\_function\_timeout) | n/a | `number` | n/a | yes |
| <a name="input_ingress_settings"></a> [ingress\_settings](#input\_ingress\_settings) | n/a | `string` | n/a | yes |
| <a name="input_max_instance_request_concurrency"></a> [max\_instance\_request\_concurrency](#input\_max\_instance\_request\_concurrency) | n/a | `number` | n/a | yes |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | n/a | `number` | n/a | yes |
| <a name="input_notifier_bucket"></a> [notifier\_bucket](#input\_notifier\_bucket) | Cloud storage bucket for file notifier | `string` | n/a | yes |
| <a name="input_notifier_pubsub_topic_id"></a> [notifier\_pubsub\_topic\_id](#input\_notifier\_pubsub\_topic\_id) | n/a | `string` | n/a | yes |
| <a name="input_notifier_service_account"></a> [notifier\_service\_account](#input\_notifier\_service\_account) | GCP service account used for the notifier | `string` | n/a | yes |
| <a name="input_notify_api_secret_id"></a> [notify\_api\_secret\_id](#input\_notify\_api\_secret\_id) | n/a | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |
| <a name="input_scheduler_timezone"></a> [scheduler\_timezone](#input\_scheduler\_timezone) | n/a | `string` | n/a | yes |
| <a name="input_vpc_connector_name"></a> [vpc\_connector\_name](#input\_vpc\_connector\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notifier_function_name_http"></a> [notifier\_function\_name\_http](#output\_notifier\_function\_name\_http) | Notifier function name |
| <a name="output_notifier_function_url_http"></a> [notifier\_function\_url\_http](#output\_notifier\_function\_url\_http) | Notifier function URL |

<!-- END_TF_DOCS -->