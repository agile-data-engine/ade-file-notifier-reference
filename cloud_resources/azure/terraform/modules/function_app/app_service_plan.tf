resource "azurerm_service_plan" "notifier" {
  name = "asp-${var.app}-${var.env}"
  resource_group_name = var.rg
  location = var.location
  os_type = "Linux"
  sku_name = "FC1"
}