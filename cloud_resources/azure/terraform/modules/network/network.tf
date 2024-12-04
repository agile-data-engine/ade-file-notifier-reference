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

resource "azurerm_nat_gateway" "notifier" {
  name                    = "ng-${var.app}-${var.env}"
  location                = var.location
  resource_group_name     = var.rg
}

resource "azurerm_public_ip" "notifier" {
  name                = "pip-${var.app}-${var.env}"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_nat_gateway_public_ip_association" "notifier" {
  nat_gateway_id       = azurerm_nat_gateway.notifier.id
  public_ip_address_id = azurerm_public_ip.notifier.id
}

resource "azurerm_subnet_nat_gateway_association" "notifier" {
  subnet_id      = azurerm_subnet.notifier.id
  nat_gateway_id = azurerm_nat_gateway.notifier.id
}