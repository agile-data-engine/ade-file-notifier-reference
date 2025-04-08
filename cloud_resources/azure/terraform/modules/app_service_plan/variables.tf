variable "app" {
    type = string
    description = "Application name to be used for resource naming"
}

variable "env" {
    type = string
    description = "Environment name"
}

variable "location" {
    type = string
    description = "Region"
}

variable "rg" {
    type = string
    description = "Resource group name"
}

variable "sku" {
    type = string
    description = "SKU name"
}

variable "tags" {
    type = map(string)
    description = "Azure tags"
}

variable "worker_count" {
    type = number
    default = null
    description = "Worker count, unset if using flex consumption plan"
}