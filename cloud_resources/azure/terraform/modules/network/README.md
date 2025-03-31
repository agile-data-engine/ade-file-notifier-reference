<!-- BEGIN_TF_DOCS -->


## About

Module for creating a virtual network, NAT gateway and public ip for the notifier Function App.

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
| [azurerm_nat_gateway.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_public_ip.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_virtual_network.notifier](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region | `string` | n/a | yes |
| <a name="input_rg"></a> [rg](#input\_rg) | Resource group name | `string` | n/a | yes |
| <a name="input_subnet_cidr_range"></a> [subnet\_cidr\_range](#input\_subnet\_cidr\_range) | Notifier subnet CIDR address space | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags | `map(string)` | n/a | yes |
| <a name="input_vnet_cidr_range"></a> [vnet\_cidr\_range](#input\_vnet\_cidr\_range) | Virtual network CIDR address space | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |

<!-- END_TF_DOCS -->