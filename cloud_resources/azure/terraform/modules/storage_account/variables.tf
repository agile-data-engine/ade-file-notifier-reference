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

variable "blob_event_queue" {
    type = string
    description = "Blob event queue name, triggers source file queuing"
}

variable "container_name" {
    type = string
    description = "Storage container for function files"
}

variable "env" {
    type = string
    description = "Environment name"
}

variable "location" {
    type = string
    description = "Region"
}

variable "name" {
    type = string
    description = "Storage account name"
}

variable "notify_queue" {
    type = string
    description = "Notify queue name, triggers notifying"
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
