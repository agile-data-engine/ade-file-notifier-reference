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

variable "external_api_base_url" {
    type = string
    description = "External API base url, e.g. https://external.services.saas.agiledataengine.com/external-api/api/s1234567/datahub/dev"
}

variable "external_api_key" {
    type = string
    sensitive = true
    description = "External API key"
}

variable "external_api_key_secret" {
    type = string
    sensitive = true
    description = "External API key secret"
}

variable "location" {
    type = string
    description = "Region"
}

variable "notify_api_base_url" {
    type = string
    description = "Notify API base url, e.g. https://external-api.dev.datahub.s1234567.saas.agiledataengine.com:443/notify-api"
}

variable "notify_api_key" {
    type = string
    sensitive = true
    description = "Notify API key"
}

variable "notify_api_key_secret" {
    type = string
    sensitive = true
    description = "Notify API key secret"
}

variable "rg" {
    type = string
    description = "Resource group name"
}

variable "security_group_ids" {
    type = list(string)
    description = "Ids of Entra security groups which are given access to resources"
}

variable "storage_account_name" {
    type = string
    description = "Name for storage account to be created"
}

variable "source_data_container" {
    type = string
    description = "Name of source data container"
}

variable "subnet_cidr_range" {
    type = string
    description = "Notifier subnet CIDR address space"
}

variable "subscription_id" {
    type = string
    description = "Azure subscription id"
}

variable "system_topic_name" {
    type = string
    description = "System topic name for source file events"
}

variable "system_topic_principal_id" {
    type = string
    description = "System topic principal id for source file events"
}

variable "system_topic_rg" {
    type = string
    description = "System topic resource group name for source file events"
}

variable "tags" {
    type = map(string)
    description = "Azure tags"
}

variable "vnet_cidr_range" {
    type = string
    description = "Virtual network CIDR address space"
}