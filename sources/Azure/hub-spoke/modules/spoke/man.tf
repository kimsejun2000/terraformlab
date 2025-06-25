resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location

  tags = local.resource_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  address_space       = [var.ip_address_range]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.resource_tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.ip_address_range, 8, 0)]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.resource_tags
}
