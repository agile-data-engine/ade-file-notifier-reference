# Terraform provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.4.0"
    }
  }
  backend "gcs" {
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

data "terraform_remote_state" "tfstate" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
  }
}