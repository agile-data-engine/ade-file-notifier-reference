variable "app" {
    type = string
    description = "Application name to be used for resource naming"
}

variable "blob_event_queue_name" {
    type = string
    description = "Blob event queue name, triggers source file queuing"
}

variable "env" {
    type = string
    description = "Environment name"
}

variable "queue_storage_account_id" {
    type = string
    description = "Id of storage account with blob event queue"
}

variable "source_data_container" {
    type = string
    description = "Name of source data container"
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