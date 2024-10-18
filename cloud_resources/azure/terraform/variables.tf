variable "allowed_ips" {
    type = list
}
variable "app" {
    type = string
}

variable "env" {
    type = string
}

variable "external_api_base_url" {
    type = string
}

variable "location" {
    type = string
}

variable "notify_api_base_url" {
    type = string
}

variable "rg" {
    type = string
}

variable "security_group_id" {
    type = string
}

variable "source_data_container" {
    type = string
}

variable "subnet_cidr_range" {
    type = string
}

variable "subscription_id" {
    type = string
}

variable "system_topic_name" {
    type = string
}

variable "system_topic_rg" {
    type = string
}

variable "vnet_cidr_range" {
    type = string
}