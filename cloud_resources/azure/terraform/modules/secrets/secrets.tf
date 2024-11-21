resource "azurerm_key_vault_secret" "notify_api_key" {
  name         = "notify-api-key"
  value        = "apikey"
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_key_vault_access_policy.user]
}

resource "azurerm_key_vault_secret" "notify_api_key_secret" {
  name         = "notify-api-key-secret"
  value        = "apikeysecret"
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_key_vault_access_policy.user]
}

resource "azurerm_key_vault_secret" "external_api_key" {
  name         = "external-api-key"
  value        = "apikey"
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_key_vault_access_policy.user]
}

resource "azurerm_key_vault_secret" "external_api_key_secret" {
  name         = "external-api-key-secret"
  value        = "apikeysecret"
  key_vault_id = azurerm_key_vault.notifier.id
  depends_on = [azurerm_key_vault_access_policy.user]
}