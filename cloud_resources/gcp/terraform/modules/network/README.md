<!-- BEGIN_TF_DOCS -->


## About

This module generates network structure for the file notifier.
Network module is usually left out, because networks are usually part of some other stack.

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
| [google_compute_address.egress_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_network.cloud_function_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.cloud_function_nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_vpc_access_connector.connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_cidr_range"></a> [cidr\_range](#input\_cidr\_range) | Network CIDR range to be used for the notifier network. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Max instances for the VPC Access Controller. | `string` | n/a | yes |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Min instances for the VPC Access Controller. | `string` | n/a | yes |
| <a name="input_nat_ip_allocate_option"></a> [nat\_ip\_allocate\_option](#input\_nat\_ip\_allocate\_option) | How external IPs should be allocated for this NAT. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region for resources | `string` | n/a | yes |
| <a name="input_source_subnetwork_ip_ranges_to_nat"></a> [source\_subnetwork\_ip\_ranges\_to\_nat](#input\_source\_subnetwork\_ip\_ranges\_to\_nat) | How NAT should be configured per Subnetwork. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_connector_name"></a> [vpc\_connector\_name](#output\_vpc\_connector\_name) | VPC connector name |

<!-- END_TF_DOCS -->