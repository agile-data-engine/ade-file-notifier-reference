resource "azurerm_key_vault_secret" "notify_api_key" {
  name         = "notify-api-key"
  value        = var.notify_api_key
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

resource "azurerm_key_vault_secret" "notify_api_key_secret" {
  name         = "notify-api-key-secret"
  value        = var.notify_api_key_secret
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

resource "azurerm_key_vault_secret" "external_api_key" {
  name         = "external-api-key"
  value        = var.external_api_key
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

resource "azurerm_key_vault_secret" "external_api_key_secret" {
  name         = "external-api-key-secret"
  value        = var.external_api_key_secret
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}