variable "project" {
  type = string
  description = "Google Cloud project"
}

variable "app" {
  type = string
  description = "Application name to be used for resource naming"
}

variable "env" {
  type = string
  description = "Environment name"
}

variable "region" {
  type = string
  description = "Region for resources"
}

variable "notifier_service_account" {
  type = string
  description = "GCP service account used for the notifier"
}

variable "notifier_bucket" {
  type = string
  description = "Cloud storage bucket for file notifier"
}

variable "function_source_code_object" {
  type = string
  description = "Function source code object"
}

variable "file_url_prefix" {
  type = string
  default = "gs://"
  description = "Prefix to be used for files."
}

variable "config_prefix" {
  type = string
  default = "data-sources/"
  description = "Folder prefix in Google Cloud storage to fetch configurations."
}

variable "max_instances" {
  type = number
}

variable "max_instance_request_concurrency" {
  type = number
}

variable "available_cpu" {
  type = string
}

variable "function_memory" {
  type = string
}

variable "function_timeout" {
  type = number
}

variable "notify_api_secret_id" {
  type = string
}

variable "external_api_secret_id" {
  type = string
}

variable "vpc_connector_name" {
  type = string
}

variable "notifier_pubsub_topic_id" {
  type = string
}

variable "ingress_settings" {
  type = string
}