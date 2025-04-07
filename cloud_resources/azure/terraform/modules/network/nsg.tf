resource "azurerm_network_security_group" "notifier" {
  name                = "nsg-${var.app}-${var.env}"
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "notifier" {
  subnet_id                 = azurerm_subnet.notifier.id
  network_security_group_id = azurerm_network_security_group.notifier.id
}

resource "azurerm_network_security_rule" "allow_outbound" {
  name                        = "AllowOutboundInternet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  network_security_group_name = azurerm_network_security_group.notifier.name
  resource_group_name         = var.rg
}

resource "azurerm_network_security_rule" "allow_inbound_vnet" {
  name                        = "AllowVnetInBound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  network_security_group_name = azurerm_network_security_group.notifier.name
  resource_group_name         = var.rg
}

resource "azurerm_network_security_rule" "deny_inbound" {
  name                        = "DenyAllOutBound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.notifier.name
  resource_group_name         = var.rg
}
