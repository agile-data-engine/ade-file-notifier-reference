variable "allowed_ips" {
    type = list
}

variable "app" {
    type = string
}

variable "entra_tenant_id" {
    type = string
}

variable "env" {
    type = string
}

variable "external_api_key" {
    type = string
    sensitive = true
}

variable "external_api_key_secret" {
    type = string
    sensitive = true
}

variable "location" {
    type = string
}

variable "notify_api_key" {
    type = string
    sensitive = true
}

variable "notify_api_key_secret" {
    type = string
    sensitive = true
}

variable "rg" {
    type = string
}

variable "security_group_id" {
    type = string
}

variable "subnet_id" {
    type = string
}