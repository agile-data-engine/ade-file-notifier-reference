output "key_vault_id" {
    value = azurerm_key_vault.notifier.id
}

output "key_vault_name" {
    value = azurerm_key_vault.notifier.name
}

output "key_vault_uri" {
    value = azurerm_key_vault.notifier.vault_uri
}