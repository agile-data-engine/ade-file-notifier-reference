# Notifier configuration bucket
resource "google_storage_bucket" "notifier_bucket" {
  name                        = var.notifier_bucket_name
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_iam_binding" "bucket_viewer" {
  bucket = google_storage_bucket.notifier_bucket.name
  role   = "roles/storage.objectViewer" # Grants the storage.objects.list permission
  members = [
    "serviceAccount:${var.notifier_service_account}"
  ]
}

resource "google_storage_bucket_iam_binding" "object_creator" {
  bucket = google_storage_bucket.notifier_bucket.name
  role   = "roles/storage.objectCreator" # Grants the storage.objects.list permission
  members = [
    "serviceAccount:${var.notifier_service_account}"
  ]
}

resource "google_storage_bucket_iam_binding" "object_user" {
  bucket = google_storage_bucket.notifier_bucket.name
  role   = "roles/storage.objectUser"
  members = [
    "serviceAccount:${var.notifier_service_account}"
  ]
}

# Listing all files in config/ folder
locals {
  datasource_files = fileset("${path.root}/${var.config_file_path}/", "*.yaml")
}

# Uploading all config files to a folder
resource "google_storage_bucket_object" "datasource_files" {
  for_each = { for file in local.datasource_files : file => file }

  name   = "data-sources/${each.value}"
  bucket = google_storage_bucket.notifier_bucket.name
  source = "${path.root}/${var.config_file_path}/${each.value}"
}