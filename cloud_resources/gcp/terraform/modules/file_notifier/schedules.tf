# List all YAML files in the config/ folder
locals {
  datasource_files = fileset("${path.root}/../../../config/", "*.yaml")
}

# Parse each YAML file
locals {
  parsed_configs = {
    for file in local.datasource_files :
    file => yamldecode(file("${path.root}/../../../config/${file}"))
  }
}

# Extract and filter valid source systems with a cron_schedule
locals {
  valid_schedules = flatten([
    for file, config in local.parsed_configs :
    [
      for source in try(config.source_systems, []) :
      source if length(try(source.cron_schedule, "")) > 0
    ]
  ])
}

# Create Google Cloud Scheduler jobs for valid configurations
resource "google_cloud_scheduler_job" "cloud_scheduler_job" {
  for_each = {
    for index, system in local.valid_schedules :
    "${index}-${system.ade_source_system}" => system
  }

  name             = "${var.app}-${each.value.ade_source_system}-schedule-${var.env}"
  schedule         = each.value.cron_schedule
  time_zone        = "UTC"
  region           = "europe-west1"
  project          = var.project

  pubsub_target {
    topic_name = var.notifier_pubsub_topic_id
    data       = base64encode(
      jsonencode({
        calls = [[each.value.ade_source_system, ""]]
      })
    )
  }
}