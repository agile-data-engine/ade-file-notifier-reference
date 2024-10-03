#resource "google_cloud_scheduler_job" "job" {
#    name        = "${var.notifierapp}-${terraform.workspace}-example"
#    description = "Notifier example schedule"
#    schedule    = var.schedule
#    region = "europe-west1"
#    project  = var.project
#    pubsub_target {
#    topic_name = google_pubsub_topic.notify_manifest_topic.id
#    data       = base64encode("[\"digitraffic/metadata_vessels\", \"digitraffic/locations_latest\"]")
#    }
#}