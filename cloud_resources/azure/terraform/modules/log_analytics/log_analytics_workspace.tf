resource "azurerm_log_analytics_workspace" "law" {
  name                = "log-${var.app}-${var.env}"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}