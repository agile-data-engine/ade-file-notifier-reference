variable "app" {
  type = string
  description = "Application name to be used for resource naming"
}

variable "env" {
  type = string
  description = "Environment name"
}

variable "notifier_bucket_name" {
  type = string
  description = "Name for the notifier bucket"
}

variable "region" {
  type = string
  description = "Region for resources"
}

variable "source_data_bucket" {
  type = string
  description = "Bucket for source data"
}

variable "function_folder" {
  type = string
  default = "functions"
  description = "Folder where functions can be found"
}

variable "notifier_service_account" {
  type = string
  description = "GCP service account used for the notifier"
}

variable "file_url_prefix" {
  type = string
  default = "gs://"
  description = "Prefix to be used for files."
}

variable "config_file_path" {
  type = string
  description = "File path for notifier config YAML-files."
}

variable "config_prefix" {
  type = string
  default = "data-sources/"
  description = "Folder prefix in Google Cloud storage to fetch configurations."
}

variable "max_instances_preprocessor" {
  type = number
  description = "Max instances to be used for Cloud function."
}

variable "max_instance_request_concurrency" {
  type = number
  description = "Max instance request concurrency for the Cloud function."
}

variable "available_cpu" {
  type = string
  description = "Available CPU for the Cloud function."
}

variable "file_event_pubsub_topic_id" {
  type = string
  description = "Pub/Sub topic id of the file events."
}

variable "notifier_pubsub_topic_id" {
  type = string
  description = "Pub/Sub topic id of the file notifier. This is used if single file manifesting is used."
}