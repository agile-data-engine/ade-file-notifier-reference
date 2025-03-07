<!-- BEGIN_TF_DOCS -->


## Terraform Deployment

Log in to Azure:
```
az login --tenant tenant_id
az account set --subscription subscription_id
```

Set API secrets as environment variables:
```
export TF_VAR_notify_api_key=secret_value
export TF_VAR_notify_api_key_secret=secret_value
export TF_VAR_external_api_key=secret_value
export TF_VAR_external_api_key_secret=secret_value
```

Deploy DEV environment:
```
terraform init -backend-config=../environments/dev/backend.conf

terraform plan -var-file="../environments/dev/terraform.tfvars"

terraform apply -var-file="../environments/dev/terraform.tfvars"
```

Cleanup generated local function files before running apply again:
```
rm -rf .output/
```

Destroy DEV deployment if needed:
```
terraform destroy -var-file="../environments/dev/terraform.tfvars"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.11 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =4.21.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.21 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_service_plan"></a> [app\_service\_plan](#module\_app\_service\_plan) | ./modules/app_service_plan | n/a |
| <a name="module_function_app"></a> [function\_app](#module\_function\_app) | ./modules/function_app | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ./modules/secrets | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | List of allowed ip addresses | `list` | n/a | yes |
| <a name="input_app"></a> [app](#input\_app) | Application name to be used for resource naming | `string` | n/a | yes |
| <a name="input_entra_tenant_id"></a> [entra\_tenant\_id](#input\_entra\_tenant\_id) | Entra tenant id | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_external_api_base_url"></a> [external\_api\_base\_url](#input\_external\_api\_base\_url) | External API base url, e.g. https://external.services.saas.agiledataengine.com/external-api/api/s1234567/datahub/dev | `string` | n/a | yes |
| <a name="input_external_api_key"></a> [external\_api\_key](#input\_external\_api\_key) | External API key | `string` | n/a | yes |
| <a name="input_external_api_key_secret"></a> [external\_api\_key\_secret](#input\_external\_api\_key\_secret) | External API key secret | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region | `string` | n/a | yes |
| <a name="input_notify_api_base_url"></a> [notify\_api\_base\_url](#input\_notify\_api\_base\_url) | Notify API base url, e.g. https://external-api.dev.datahub.s1234567.saas.agiledataengine.com:443/notify-api | `string` | n/a | yes |
| <a name="input_notify_api_key"></a> [notify\_api\_key](#input\_notify\_api\_key) | Notify API key | `string` | n/a | yes |
| <a name="input_notify_api_key_secret"></a> [notify\_api\_key\_secret](#input\_notify\_api\_key\_secret) | Notify API key secret | `string` | n/a | yes |
| <a name="input_rg"></a> [rg](#input\_rg) | Resource group name | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Id of Entra security group which is given access to resources | `string` | n/a | yes |
| <a name="input_source_data_container"></a> [source\_data\_container](#input\_source\_data\_container) | Name of source data container | `string` | n/a | yes |
| <a name="input_subnet_cidr_range"></a> [subnet\_cidr\_range](#input\_subnet\_cidr\_range) | Notifier subnet CIDR address space | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription id | `string` | n/a | yes |
| <a name="input_system_topic_name"></a> [system\_topic\_name](#input\_system\_topic\_name) | System topic name for source file events | `string` | n/a | yes |
| <a name="input_system_topic_principal_id"></a> [system\_topic\_principal\_id](#input\_system\_topic\_principal\_id) | System topic principal id for source file events | `string` | n/a | yes |
| <a name="input_system_topic_rg"></a> [system\_topic\_rg](#input\_system\_topic\_rg) | System topic resource group name for source file events | `string` | n/a | yes |
| <a name="input_vnet_cidr_range"></a> [vnet\_cidr\_range](#input\_vnet\_cidr\_range) | Virtual network CIDR address space | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->