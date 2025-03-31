<!-- BEGIN_TF_DOCS -->


## About

Module for creating an App Service Plan for the Function App.

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
| [azurerm_service_plan.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region | `string` | n/a | yes |
| <a name="input_rg"></a> [rg](#input\_rg) | Resource group name | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | SKU name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags | `map(string)` | n/a | yes |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | Worker count | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asp_id"></a> [asp\_id](#output\_asp\_id) | App Service Plan id |

<!-- END_TF_DOCS -->