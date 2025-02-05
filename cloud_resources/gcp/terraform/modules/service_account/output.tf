output "notifier_service_account" {
  description = "Notifier service account"
  value       = google_service_account.account.email
}