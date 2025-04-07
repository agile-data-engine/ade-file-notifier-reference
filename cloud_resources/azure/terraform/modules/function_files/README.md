<!-- BEGIN_TF_DOCS -->


## About

Module for generating files and folders for Function App deployment. Files are copied from the function folder, timer_trigger_function module is called to generate timer trigger functions based on the configuration.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.21 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_timer_trigger_function"></a> [timer\_trigger\_function](#module\_timer\_trigger\_function) | ../timer_trigger_function | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_blob.config-files](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [local_file.host_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.notify_function_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.notify_notify_py](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.queue_file_function_json](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.queue_file_queue_file_py](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.requirements_txt](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.shared_azure_handler_py](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.shared_notifier_common_py](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_folder"></a> [config\_folder](#input\_config\_folder) | Local folder name for config files | `string` | n/a | yes |
| <a name="input_config_prefix"></a> [config\_prefix](#input\_config\_prefix) | Target folder name for config files | `string` | n/a | yes |
| <a name="input_function_folder"></a> [function\_folder](#input\_function\_folder) | Local folder name for function files | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Notifier storage account name | `string` | n/a | yes |
| <a name="input_storage_container_name"></a> [storage\_container\_name](#input\_storage\_container\_name) | Notifier storage container name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_output_folder"></a> [function\_output\_folder](#output\_function\_output\_folder) | Local output folder |

<!-- END_TF_DOCS -->