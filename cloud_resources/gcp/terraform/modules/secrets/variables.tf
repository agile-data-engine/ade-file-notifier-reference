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