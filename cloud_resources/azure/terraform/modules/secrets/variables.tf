variable "allowed_ips" {
    type = list
    description = "List of allowed ip addresses"
}

variable "app" {
    type = string
    description = "Application name to be used for resource naming"
}

variable "entra_tenant_id" {
    type = string
    description = "Entra tenant id"
}

variable "env" {
    type = string
    description = "Environment name"
}

variable "external_api_key" {
    type = string
    sensitive = true
    description = "ADE External API key"
}

variable "external_api_key_secret" {
    type = string
    sensitive = true
    description = "ADE External API key secret"
}

variable "location" {
    type = string
    description = "Region"
}

variable "notify_api_key" {
    type = string
    sensitive = true
    description = "ADE Notify API key"
}

variable "notify_api_key_secret" {
    type = string
    sensitive = true
    description = "ADE Notify API key secret"
}

variable "rg" {
    type = string
    description = "Resource group name"
}

variable "security_group_id" {
    type = string
    description = "Id of Entra security group which is given access to resources"
}

variable "subnet_id" {
    type = string
    description = "Subnet id for the Function App vnet configuration"
}