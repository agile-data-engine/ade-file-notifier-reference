# Function zip archive
data "archive_file" "function_archive" {
  type        = "zip"
  output_path = "${path.root}/.output/${var.function_folder}/functions.zip"

  source {
    filename = "main.py"
    content  = file("${path.root}/${var.function_folder}/gcp/main.py")
  }

  source {
    filename = "common/notifier_common.py"
    content  = file("${path.root}/${var.function_folder}/common/notifier_common.py")
  }

  source {
    filename = "gcp_handler.py"
    content  = file("${path.root}/${var.function_folder}/gcp/gcp_handler.py")
  }

  source {
    filename = "requirements.txt"
    content  = file("${path.root}/${var.function_folder}/gcp/requirements.txt")
  }
}

# Function zip archive bucket object
resource "google_storage_bucket_object" "function_object" {
  name   = "functions-source-code/${var.function_folder}/${data.archive_file.function_archive.output_md5}.zip"
  bucket = google_storage_bucket.notifier_bucket.name
  source = data.archive_file.function_archive.output_path
}


# Cloud function: file_foldering
resource "google_cloudfunctions2_function" "file_foldering_function" {
  name     = "gcf-${var.app}-event-foldering-${var.env}"
  location = var.region
  build_config {
    runtime     = "python312"
    entry_point = "file_foldering"
    source {
      storage_source {
        bucket = google_storage_bucket.notifier_bucket.name
        object = google_storage_bucket_object.function_object.name
      }
    }
  }
  service_config {
    timeout_seconds  = 60
    available_memory = "256M"
    environment_variables = {
      NOTIFIER_BUCKET       = google_storage_bucket.notifier_bucket.name
      CONFIG_PREFIX         = var.config_prefix
      FILE_URL_PREFIX       = var.file_url_prefix
      NOTIFIER_PUBSUB_TOPIC = var.notifier_pubsub_topic_id
    }
    max_instance_count               = var.max_instances_preprocessor
    max_instance_request_concurrency = var.max_instance_request_concurrency
    available_cpu                    = var.available_cpu
    service_account_email            = var.notifier_service_account
  }
  event_trigger {
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = var.file_event_pubsub_topic_id
    retry_policy          = "RETRY_POLICY_RETRY"
    trigger_region        = var.region
    service_account_email = var.notifier_service_account
  }
}