output "notifier_pubsub_topic_id" {
  description = "Notifier pubsub id"
  value       = google_pubsub_topic.add_to_manifest_topic.id
}

output "file_event_pubsub_topic_id" {
  description = "File event pubsub id"
  value       = google_pubsub_topic.file_event_topic.id
}