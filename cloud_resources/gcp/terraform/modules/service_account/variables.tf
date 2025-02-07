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