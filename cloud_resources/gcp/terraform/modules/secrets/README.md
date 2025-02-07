<!-- BEGIN_TF_DOCS -->


## About

Secret manager for API secrets.

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
| [google_secret_manager_secret.external_api_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.notify_api_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_binding.external_api_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding) | resource |
| [google_secret_manager_secret_iam_binding.notify_api_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_notifier_service_account"></a> [notifier\_service\_account](#input\_notifier\_service\_account) | GCP service account used for the notifier | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_api_secret_id"></a> [external\_api\_secret\_id](#output\_external\_api\_secret\_id) | n/a |
| <a name="output_external_api_secret_name"></a> [external\_api\_secret\_name](#output\_external\_api\_secret\_name) | n/a |
| <a name="output_notify_api_secret_id"></a> [notify\_api\_secret\_id](#output\_notify\_api\_secret\_id) | n/a |
| <a name="output_notify_api_secret_name"></a> [notify\_api\_secret\_name](#output\_notify\_api\_secret\_name) | n/a |

<!-- END_TF_DOCS -->