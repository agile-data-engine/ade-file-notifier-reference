<!-- BEGIN_TF_DOCS -->


## About

Module for creating a Function App, Application Insights and role assignments/access policies for working with storage, queues and key vault.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.21 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_function_files"></a> [function\_files](#module\_function\_files) | ../function_files | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_key_vault_access_policy.notifier-access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_linux_function_app.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_role_assignment.notifier-blob-owner](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.notifier-queue-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.notifier-storage-contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [archive_file.function_archive](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_ranges"></a> [allowed\_cidr\_ranges](#input\_allowed\_cidr\_ranges) | List of allowed cidr ip address ranges | `list(string)` | n/a | yes |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | List of allowed vnet subnet ids | `list(string)` | n/a | yes |
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_asp_id"></a> [asp\_id](#input\_asp\_id) | App Service Plan id | `string` | n/a | yes |
| <a name="input_blob_event_queue"></a> [blob\_event\_queue](#input\_blob\_event\_queue) | Blob event queue name, triggers source file queuing | `string` | n/a | yes |
| <a name="input_config_folder"></a> [config\_folder](#input\_config\_folder) | Local folder name for config files | `string` | n/a | yes |
| <a name="input_config_prefix"></a> [config\_prefix](#input\_config\_prefix) | Target folder name for config files | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Storage container for function files | `string` | n/a | yes |
| <a name="input_entra_tenant_id"></a> [entra\_tenant\_id](#input\_entra\_tenant\_id) | Entra tenant id | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_external_api_base_url"></a> [external\_api\_base\_url](#input\_external\_api\_base\_url) | External API base url, e.g. https://external.services.saas.agiledataengine.com/external-api/api/s1234567/datahub/dev | `string` | n/a | yes |
| <a name="input_function_folder"></a> [function\_folder](#input\_function\_folder) | Local folder name for function files | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Key vault id | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Key vault name | `string` | n/a | yes |
| <a name="input_key_vault_uri"></a> [key\_vault\_uri](#input\_key\_vault\_uri) | Key vault URI | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace id | `string` | n/a | yes |
| <a name="input_notify_api_base_url"></a> [notify\_api\_base\_url](#input\_notify\_api\_base\_url) | Notify API base url, e.g. https://external-api.dev.datahub.s1234567.saas.agiledataengine.com:443/notify-api | `string` | n/a | yes |
| <a name="input_notify_queue"></a> [notify\_queue](#input\_notify\_queue) | Notify queue name, triggers notifying | `string` | n/a | yes |
| <a name="input_rg"></a> [rg](#input\_rg) | Resource group name | `string` | n/a | yes |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Storage account id | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Storage account name | `string` | n/a | yes |
| <a name="input_storage_primary_blob_endpoint"></a> [storage\_primary\_blob\_endpoint](#input\_storage\_primary\_blob\_endpoint) | Storage account primary blob endpoint | `string` | n/a | yes |
| <a name="input_storage_primary_queue_endpoint"></a> [storage\_primary\_queue\_endpoint](#input\_storage\_primary\_queue\_endpoint) | Storage account primary queue endpoint | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id for the Function App vnet configuration | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags | `map(string)` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->