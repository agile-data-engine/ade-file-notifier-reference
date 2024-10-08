resource "google_cloud_scheduler_job" "job" {
    name        = "${var.app}-${var.env}-example"
    description = "Notifier example schedule"
    schedule    = var.schedule
    region = "europe-west1"
    project  = var.project
    pubsub_target {
    topic_name = google_pubsub_topic.add_to_manifest_topic.id
    data       = base64encode("{\"calls\":[[\"digitraffic\", \"\"]]}")
    }
}