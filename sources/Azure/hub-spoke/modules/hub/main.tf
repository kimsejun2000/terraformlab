resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = local.location

  tags = local.resource_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.resource_tags
}

resource "azurerm_subnet" "bastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.254.0/27"]
}

resource "azurerm_public_ip" "pip" {
  name                = "bastion-pip"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.resource_tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "hub-bastion"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = local.resource_tags
}