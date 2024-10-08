# External API secrets
resource "google_secret_manager_secret" "external_api_secret" {
  secret_id = "secret_external_api_${var.env}"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

# Notify API secrets
resource "google_secret_manager_secret" "notify_api_secret" {
  secret_id = "secret_notify_api_${var.env}"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_iam_binding" "notify_api_access" {
  secret_id   = google_secret_manager_secret.notify_api_secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = ["serviceAccount:${var.notifier_service_account}"]
}

resource "google_secret_manager_secret_iam_binding" "external_api_access" {
  secret_id   = google_secret_manager_secret.external_api_secret.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = ["serviceAccount:${var.notifier_service_account}"]
}