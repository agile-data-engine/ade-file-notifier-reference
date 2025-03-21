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

variable "notifier_pubsub_topic_id" {
  type = string
  description = "Notifier Pub/Sub topic ID"
}

variable "scheduler_timezone" {
  type = string
  description = "Timezone for Cloud Scheduler"
}

variable "config_file_path" {
  type = string
  description = "File path for notifier config YAML-files"
}