output "notify_api_secret_id" {
  value = google_secret_manager_secret.notify_api_secret.secret_id
}

output "notify_api_secret_name" {
  value = google_secret_manager_secret.notify_api_secret.name
}

output "external_api_secret_id" {
  value = google_secret_manager_secret.external_api_secret.secret_id
}

output "external_api_secret_name" {
  value = google_secret_manager_secret.external_api_secret.name
}
