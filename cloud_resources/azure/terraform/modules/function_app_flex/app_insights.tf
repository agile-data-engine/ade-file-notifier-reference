resource "azurerm_application_insights" "notifier" {
  name                = "appi-${var.app}-${var.env}"
  location            = var.location
  resource_group_name = var.rg
  application_type    = "web"
  workspace_id = var.log_analytics_workspace_id
  tags = var.tags
}