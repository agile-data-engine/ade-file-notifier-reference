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

variable "worker_count" {
    type = number
    description = "Worker count"
}