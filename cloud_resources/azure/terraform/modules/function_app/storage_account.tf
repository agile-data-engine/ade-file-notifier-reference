resource "azurerm_storage_account" "notifier" {
  name                     = "st${var.app}${var.env}"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = true # ENABLED FOR LOCAL DEV, CHANGE TO false
}

resource "azurerm_storage_container" "notifier" {
  name                  = var.container_name
  storage_account_id  = azurerm_storage_account.notifier.id
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "notifier" {
  storage_account_id = azurerm_storage_account.notifier.id

  default_action             = "Allow" # ENABLED FOR LOCAL DEV, CHANGE TO "Deny"
  ip_rules                   = var.allowed_ips
  virtual_network_subnet_ids = [var.subnet_id]
  bypass                     = ["AzureServices"]
}

resource "azurerm_storage_queue" "blob-event-queue" {
  name = var.blob_event_queue
  storage_account_name = azurerm_storage_account.notifier.name
}

resource "azurerm_storage_queue" "notify-queue" {
  name = var.notify_queue
  storage_account_name = azurerm_storage_account.notifier.name
}

resource "azurerm_role_assignment" "group-blob-owner" {
  principal_id         = var.security_group_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.notifier.id
}

resource "azurerm_role_assignment" "group-queue-contributor" {
  principal_id         = var.security_group_id
  role_definition_name = "Storage Queue Data Contributor"
  scope                = azurerm_storage_account.notifier.id
}