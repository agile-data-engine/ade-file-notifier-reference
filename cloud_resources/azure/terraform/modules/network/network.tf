resource "azurerm_virtual_network" "notifier" {
  name                = "vnet-${var.app}-${var.env}"
  address_space       = [var.vnet_cidr_range]
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_subnet" "notifier" {
  name                 = "snet-${var.app}"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.notifier.name
  address_prefixes     = [var.subnet_cidr_range]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
  delegation {
    name = "Microsoft.Web/serverFarms"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}