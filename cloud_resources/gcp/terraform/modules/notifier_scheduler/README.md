<!-- BEGIN_TF_DOCS -->


## About

This module creates Cloud Scheduler schedules, if those are given in the configuration files.

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_config_file_path"></a> [config\_file\_path](#input\_config\_file\_path) | File path for notifier config YAML-files | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_notifier_pubsub_topic_id"></a> [notifier\_pubsub\_topic\_id](#input\_notifier\_pubsub\_topic\_id) | Notifier Pub/Sub topic ID | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |
| <a name="input_scheduler_timezone"></a> [scheduler\_timezone](#input\_scheduler\_timezone) | Timezone for Cloud Scheduler | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->