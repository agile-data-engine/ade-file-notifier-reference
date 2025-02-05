variable "project" {
  type = string
}

variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "notifier_service_account" {
  type = string
}

variable "notifier_bucket" {
  type = string
}

variable "function_source_code_object" {
  type = string
}

variable "file_url_prefix" {
  type = string
}

variable "config_prefix" {
  type = string
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