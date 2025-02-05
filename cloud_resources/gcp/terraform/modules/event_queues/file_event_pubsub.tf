# Topic: file_event_topic
resource "google_pubsub_topic" "file_event_topic" {
  name = "pst-${var.app}-file-event-${var.env}"
}

# Topic IAM bindings
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_pubsub_topic_iam_binding" "file_event_topic_binding" {
  topic   = google_pubsub_topic.file_event_topic.id
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

# Attach PubSub to Storage notifications
resource "google_storage_notification" "file_notification" {
  bucket         = var.source_data_bucket
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.file_event_topic.id
  event_types    = ["OBJECT_FINALIZE", "OBJECT_METADATA_UPDATE"]
  depends_on     = [google_pubsub_topic_iam_binding.file_event_topic_binding]
}