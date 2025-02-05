output "notifier_bucket_name" {
  description = "Notifier bucket name"
  value       = google_storage_bucket.notifier_bucket.name
}

output "notifier_bucket_source_code_object" {
  description = "Source code object for functions in notifier bucket"
  value       = google_storage_bucket_object.function_object.name
}