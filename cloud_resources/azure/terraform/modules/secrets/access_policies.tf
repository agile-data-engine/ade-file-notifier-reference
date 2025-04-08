resource "azurerm_key_vault_access_policy" "user" {
    key_vault_id = azurerm_key_vault.notifier.id
    tenant_id    = var.entra_tenant_id
    for_each     = toset(var.security_group_ids)
    object_id    = each.value

    secret_permissions = [
        "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
}
