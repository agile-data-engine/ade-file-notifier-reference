# Cloud function: add_to_manifest
resource "google_cloudfunctions2_function" "add_to_manifest_function" {
  name = "gcf-${var.app}-add-to-manifest-${var.env}"
  location = var.region
  build_config {
    runtime = "python312"
    entry_point = "add_to_manifest"
    source {
      storage_source {
        bucket = var.notifier_bucket
        object = var.function_source_code_object
      }
    }
  }
  service_config {
    timeout_seconds = var.function_timeout
    available_memory = var.function_memory

    environment_variables = {
      SERVICE_ACCOUNT_EMAIL = var.notifier_service_account
      NOTIFIER_BUCKET = var.notifier_bucket
      CONFIG_PREFIX = var.config_prefix
    }
    secret_environment_variables {
      key = "NOTIFY_API_SECRET_ID"
      project_id = var.project
      secret = var.notify_api_secret_id
      version = "latest"
    }
    max_instance_count = var.max_instances
    max_instance_request_concurrency = var.max_instance_request_concurrency
    available_cpu = var.available_cpu
    service_account_email = var.notifier_service_account
    vpc_connector = var.vpc_connector_name
    vpc_connector_egress_settings = "ALL_TRAFFIC"
  }
  event_trigger {
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.add_to_manifest_topic.id
    retry_policy = "RETRY_POLICY_RETRY"
    trigger_region = var.region
    service_account_email = var.notifier_service_account
  }
}