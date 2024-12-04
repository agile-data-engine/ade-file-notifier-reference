variable "project" {
  type = string
}

# Notifier app name used in resource naming
variable "app" {
    type = string
}

variable "region" {
    type = string
}

variable "env" {
    type = string
}

variable "state_bucket" {
    type = string
}

variable "source_data_bucket" {
    type = string
}

variable "cidr_range" {
    type = string
}

variable "vpc_connector_name" {
    type = string
}

variable "config_files" {
  description = "List of YAML files in the config directory"
  type        = list(string)
  default     = []
}