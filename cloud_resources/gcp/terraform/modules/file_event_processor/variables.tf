variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "source_data_bucket" {
  type = string
}

variable "function_folder" {
  type = string
}

variable "notifier_service_account" {
  type = string
}

variable "file_url_prefix" {
  type = string
}

variable "config_prefix" {
  type = string
}

variable "max_instances_preprocessor" {
  type = number
}

variable "max_instance_request_concurrency" {
  type = number
}

variable "available_cpu" {
  type = string
}

variable "file_event_pubsub_topic_id" {
  type = string
}

variable "notifier_pubsub_topic_id" {
  type = string
}