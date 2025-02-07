<!-- BEGIN_TF_DOCS -->


## About

This module generates event "queues", which in practice are Pub/Sub topics.
One Pub/Sub topic for file events from Cloud Storage bucket and another for file notifier single_file_manifest functionality.

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
| [google_pubsub_topic.add_to_manifest_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic.file_event_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_binding.add_to_manifest_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [google_pubsub_topic_iam_binding.file_event_topic_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [google_storage_notification.file_notification](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_notification) | resource |
| [google_storage_project_service_account.gcs_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_notifier_service_account"></a> [notifier\_service\_account](#input\_notifier\_service\_account) | GCP service account used for the notifier | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |
| <a name="input_source_data_bucket"></a> [source\_data\_bucket](#input\_source\_data\_bucket) | Bucket for source data | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_event_pubsub_topic_id"></a> [file\_event\_pubsub\_topic\_id](#output\_file\_event\_pubsub\_topic\_id) | File event pubsub id |
| <a name="output_notifier_pubsub_topic_id"></a> [notifier\_pubsub\_topic\_id](#output\_notifier\_pubsub\_topic\_id) | Notifier pubsub id |

<!-- END_TF_DOCS -->