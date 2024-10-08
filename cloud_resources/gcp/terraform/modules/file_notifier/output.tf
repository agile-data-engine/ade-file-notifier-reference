output "notifier_function_name_http" {
    description = "Notifier function name"
    value = google_cloudfunctions2_function.add_to_manifest_function_http.name
}


output "notifier_function_url_http" {
    description = "Notifier function URL"
    value = google_cloudfunctions2_function.add_to_manifest_function_http.url
}