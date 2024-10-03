terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.4.0"
    }
  }
}

resource "google_storage_bucket" "terraform_state_bucke" {
  name          = "${var.app}-tfstate-${var.env}"
  project       = var.project
  location      = var.region
  force_destroy = false

  # Enable versioning to protect state files
  versioning {
    enabled = true
  }

  # Enable uniform bucket-level access for centralized IAM permissions
  uniform_bucket_level_access = true
}
