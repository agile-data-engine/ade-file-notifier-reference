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

variable "subnet_cidr_range" {
    type = string
    description = "Notifier subnet CIDR address space"
}

variable "vnet_cidr_range" {
    type = string
    description = "Virtual network CIDR address space"
}