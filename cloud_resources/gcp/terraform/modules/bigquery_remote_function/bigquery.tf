resource "google_bigquery_dataset" "notifier_ds" {
  dataset_id          = "file_notifier"
  location            = var.region
  project             = var.project
  is_case_insensitive = true
}

# Connection from BigQuery to Cloud function
resource "google_bigquery_connection" "connection" {
  connection_id = "ade_notifier_remote_function"
  project       = var.project
  location      = var.region
  cloud_resource {
  }
}

resource "google_cloud_run_service_iam_binding" "default" {
  location = var.region
  project  = var.project
  service  = var.notifier_function_name
  role     = "roles/run.invoker"
  members = [
    format("serviceAccount:%s", google_bigquery_connection.connection.cloud_resource[0].service_account_id)
  ]
}

resource "google_bigquery_routine" "create_function" {
  dataset_id      = google_bigquery_dataset.notifier_ds.dataset_id
  project         = var.project
  routine_id      = "create_adenotifier_function"
  routine_type    = "PROCEDURE"
  language        = "SQL"
  definition_body = <<EOT
      CREATE OR REPLACE FUNCTION `${var.project}.${google_bigquery_dataset.notifier_ds.dataset_id}`.file_notifier_call(ade_source_system STRING, ade_source_entity STRING) 
      RETURNS JSON
      REMOTE WITH CONNECTION `${var.project}.${var.region}.${google_bigquery_connection.connection.connection_id}`
      OPTIONS (
          endpoint = '${var.notifier_function_url}'
      );
  EOT
}