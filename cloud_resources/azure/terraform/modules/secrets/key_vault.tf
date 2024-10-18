resource "azurerm_key_vault" "notifier" {
    name                       = "kv-${var.app}-${var.env}"
    location                   = var.location
    resource_group_name        = var.rg
    tenant_id                  = data.azurerm_client_config.current.tenant_id
    sku_name                   = "standard"
    soft_delete_retention_days = 7
    network_acls {
      bypass = "None"
      default_action = "Deny"
      ip_rules = var.allowed_ips
      virtual_network_subnet_ids = [var.subnet_id]
    }
}