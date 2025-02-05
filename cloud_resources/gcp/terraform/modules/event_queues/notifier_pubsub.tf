# Topic: add_to_manifest
resource "google_pubsub_topic" "add_to_manifest_topic" {
  name = "pst-${var.app}-add-to-manifest-${var.env}"
}

resource "google_pubsub_topic_iam_binding" "add_to_manifest_binding" {
  topic = google_pubsub_topic.add_to_manifest_topic.id
  role  = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}",
    "serviceAccount:${var.notifier_service_account}"
  ]
}