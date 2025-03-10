output "blob_event_queue_name" {
    value = azurerm_storage_queue.blob-event-queue.name
    description = "Blob event queue name"
}

output "container_name" {
    value = azurerm_storage_container.notifier.name
    description = "Container name"
}

output "id" {
    value = azurerm_storage_account.notifier.id
    description = "Storage account id"
}

output "name" {
    value = azurerm_storage_account.notifier.name
    description = "Storage account name"
}

output "notify_queue_name" {
    value = azurerm_storage_queue.notify-queue.name
    description = "Notify queue name"
}

output "primary_blob_endpoint" {
    value = azurerm_storage_account.notifier.primary_blob_endpoint
    description = "Storage account primary blob endpoint"
}

output "primary_queue_endpoint" {
    value = azurerm_storage_account.notifier.primary_queue_endpoint
    description = "Storage account primary queue endpoint"
}