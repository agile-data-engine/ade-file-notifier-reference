<!-- BEGIN_TF_DOCS -->


## About

Module for creating a Function App and related components including:
- Application Insights
- Storage account with queues for triggering the functions and blob containers for function files
- Event subscription for blob created source file events
- Role assignments

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.21 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventgrid_system_topic_event_subscription.topic-queue-message-sender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic_event_subscription) | resource |
| [azurerm_role_assignment.topic-queue-message-sender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_blob_event_queue_name"></a> [blob\_event\_queue\_name](#input\_blob\_event\_queue\_name) | Blob event queue name, triggers source file queuing | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_queue_storage_account_id"></a> [queue\_storage\_account\_id](#input\_queue\_storage\_account\_id) | Id of storage account with blob event queue | `string` | n/a | yes |
| <a name="input_source_data_container"></a> [source\_data\_container](#input\_source\_data\_container) | Name of source data container | `string` | n/a | yes |
| <a name="input_system_topic_name"></a> [system\_topic\_name](#input\_system\_topic\_name) | System topic name for source file events | `string` | n/a | yes |
| <a name="input_system_topic_principal_id"></a> [system\_topic\_principal\_id](#input\_system\_topic\_principal\_id) | System topic principal id for source file events | `string` | n/a | yes |
| <a name="input_system_topic_rg"></a> [system\_topic\_rg](#input\_system\_topic\_rg) | System topic resource group name for source file events | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->