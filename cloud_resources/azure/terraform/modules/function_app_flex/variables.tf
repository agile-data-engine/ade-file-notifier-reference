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

variable "asp_id" {
    type = string
    description = "App Service Plan id"
}

variable "blob_event_queue" {
    type = string
    description = "Blob event queue name, triggers source file queuing"
}

variable "config_folder" {
    type = string
    description = "Local folder name for config files"
}

variable "config_prefix" {
    type = string
    description = "Target folder name for config files"
}

variable "container_name" {
    type = string
    description = "Storage container for function files"
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

variable "function_folder" {
    type = string
    description = "Local folder name for function files"
}

variable "key_vault_id" {
    type = string
    description = "Key vault id"
}

variable "key_vault_name" {
    type = string
    description = "Key vault name"
}

variable "key_vault_uri" {
    type = string
    description = "Key vault URI"
}

variable "location" {
    type = string
    description = "Region"
}

variable "log_analytics_workspace_id" {
    type = string
    description = "Log Analytics Workspace id"
}

variable "notify_queue" {
    type = string
    description = "Notify queue name, triggers notifying"
}

variable "notify_api_base_url" {
    type = string
    description = "Notify API base url, e.g. https://external-api.dev.datahub.s1234567.saas.agiledataengine.com:443/notify-api"
}

variable "rg" {
    type = string
    description = "Resource group name"
}

variable "subnet_id" {
    type = string
    description = "Subnet id for the Function App vnet configuration"
}

variable "storage_account_id" {
    type = string
    description = "Storage account id"
}

variable "storage_account_name" {
    type = string
    description = "Storage account name"
}

variable "storage_primary_blob_endpoint" {
    type = string
    description = "Storage account primary blob endpoint"
}

variable "storage_primary_queue_endpoint" {
    type = string
    description = "Storage account primary queue endpoint"
}

variable "storage_primary_table_endpoint" {
    type = string
    description = "Storage account primary table endpoint"
}

variable "tags" {
    type = map(string)
    description = "Azure tags"
}