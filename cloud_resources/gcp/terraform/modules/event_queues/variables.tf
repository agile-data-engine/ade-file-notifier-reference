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

variable "source_data_bucket" {
  type = string
  description = "Bucket for source data"
}

variable "notifier_service_account" {
  type = string
  description = "GCP service account used for the notifier"
}