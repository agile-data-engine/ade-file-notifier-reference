<!-- BEGIN_TF_DOCS -->


## About

Module for creating a storage account with queues for triggering the functions and blob containers for function files.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.21 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.group-blob-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.group-queue-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_queue.blob-event-queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_queue.notify-queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_ranges"></a> [allowed\_cidr\_ranges](#input\_allowed\_cidr\_ranges) | List of allowed cidr ip address ranges | `list(string)` | n/a | yes |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | List of allowed vnet subnet ids | `list(string)` | n/a | yes |
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_blob_event_queue"></a> [blob\_event\_queue](#input\_blob\_event\_queue) | Blob event queue name, triggers source file queuing | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Storage container for function files | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Storage account name | `string` | n/a | yes |
| <a name="input_notify_queue"></a> [notify\_queue](#input\_notify\_queue) | Notify queue name, triggers notifying | `string` | n/a | yes |
| <a name="input_rg"></a> [rg](#input\_rg) | Resource group name | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Ids of Entra security groups which are given access to resources | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blob_event_queue_name"></a> [blob\_event\_queue\_name](#output\_blob\_event\_queue\_name) | Blob event queue name |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Container name |
| <a name="output_id"></a> [id](#output\_id) | Storage account id |
| <a name="output_name"></a> [name](#output\_name) | Storage account name |
| <a name="output_notify_queue_name"></a> [notify\_queue\_name](#output\_notify\_queue\_name) | Notify queue name |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Storage account primary blob endpoint |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | Storage account primary queue endpoint |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | Storage account primary table endpoint |

<!-- END_TF_DOCS -->