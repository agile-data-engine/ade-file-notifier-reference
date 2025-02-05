# Service account
resource "google_service_account" "account" {
  account_id   = "sa-${var.app}-${var.env}"
  display_name = "Service account for ${var.app}-${var.env}"
}

# Role grants
resource "google_project_iam_member" "run_invoker" {
  project = var.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.account.email}"
}
resource "google_project_iam_member" "event_receiver" {
  project = var.project
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.account.email}"
}