variable "allowed_cidr_ranges" {
    type = list(string)
    description = "List of allowed cidr ip address ranges"
}

variable "allowed_subnet_ids" {
    type = list(string)
    description = "List of allowed vnet subnet ids"
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

variable "security_group_ids" {
    type = list(string)
    description = "Ids of Entra security groups which are given access to resources"
}

variable "tags" {
    type = map(string)
    description = "Azure tags"
}