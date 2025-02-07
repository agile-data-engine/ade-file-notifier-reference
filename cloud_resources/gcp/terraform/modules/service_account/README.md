<!-- BEGIN_TF_DOCS -->


## About

Service account for File Notifier.

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
| [google_project_iam_member.event_receiver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.run_invoker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Google Cloud project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_notifier_service_account"></a> [notifier\_service\_account](#output\_notifier\_service\_account) | Notifier service account |

<!-- END_TF_DOCS -->