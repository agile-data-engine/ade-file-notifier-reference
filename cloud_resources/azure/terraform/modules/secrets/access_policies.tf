resource "azurerm_role_assignment" "kv_secrets_officer" {
    for_each             = toset(var.security_group_ids)
    scope                = azurerm_key_vault.notifier.id
    role_definition_name = "Key Vault Secrets Officer"
    principal_id         = each.value
}
