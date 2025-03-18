<!-- BEGIN_TF_DOCS -->


## About

Module for generating timer trigger functions based on schedules configured in notifier config files.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.function_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.timer_trigger_py](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cron_expression"></a> [cron\_expression](#input\_cron\_expression) | Function cron schedule | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of timer trigger function | `string` | n/a | yes |
| <a name="input_function_output_folder"></a> [function\_output\_folder](#input\_function\_output\_folder) | Local output folder | `string` | n/a | yes |
| <a name="input_trigger_message"></a> [trigger\_message](#input\_trigger\_message) | Trigger message defining which sources to notify | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->