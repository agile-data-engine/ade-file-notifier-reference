resource "azurerm_storage_account" "notifier" {
  name                     = var.name
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = false
  tags = var.tags
}

resource "azurerm_storage_container" "notifier" {
  name                = var.container_name
  storage_account_id  = azurerm_storage_account.notifier.id
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "notifier" {
  storage_account_id = azurerm_storage_account.notifier.id
  default_action             = "Deny"
  ip_rules                   = [for ip in var.allowed_cidr_ranges : replace(ip, "/32", "")] # Storage account does not accept /32
  virtual_network_subnet_ids = toset(var.allowed_subnet_ids)
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

resource "azurerm_role_assignment" "group-blob-contributor" {
  for_each             = toset(var.security_group_ids)
  principal_id         = each.value
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.notifier.id
}

resource "azurerm_role_assignment" "group-queue-contributor" {
  for_each             = toset(var.security_group_ids)
  principal_id         = each.value
  role_definition_name = "Storage Queue Data Contributor"
  scope                = azurerm_storage_account.notifier.id
}