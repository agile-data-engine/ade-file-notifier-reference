variable "config_folder" {
    type = string
    description = "Local folder name for config files"
}

variable "config_prefix" {
    type = string
    description = "Target folder name for config files"
}

variable "function_folder" {
    type = string
    description = "Local folder name for function files"
}

variable "storage_account_name" {
    type = string
    description = "Notifier storage account name"
}

variable "storage_container_name" {
    type = string
    description = "Notifier storage container name"
}