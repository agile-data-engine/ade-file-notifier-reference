<!-- BEGIN_TF_DOCS -->


## About

Module for optional BigQuery remote function to call file notifier.

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
| [google_bigquery_connection.connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_connection) | resource |
| [google_bigquery_dataset.notifier_ds](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_routine.create_function](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_routine) | resource |
| [google_cloud_run_service_iam_binding.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | n/a | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | n/a | yes |
| <a name="input_notifier_function_name"></a> [notifier\_function\_name](#input\_notifier\_function\_name) | n/a | `string` | n/a | yes |
| <a name="input_notifier_function_url"></a> [notifier\_function\_url](#input\_notifier\_function\_url) | n/a | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->