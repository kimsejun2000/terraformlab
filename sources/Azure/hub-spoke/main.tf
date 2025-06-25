provider "azurerm" {
  features {}
}

module "hub" {
    source = "./modules/hub"
}

module "spoke01" {
    source = "./modules/spoke"
    name = "spoke01"
    location = "koreacentral"
    ip_address_range = "10.10.0.0/16"
}

module "spoke01-instance1" {
  source               = "./modules/create_vm"
  resource_group_name  = module.spoke01.virtual_network.resource_group_name
  virtual_network_name = module.spoke01.virtual_network.name
  subnet_name          = module.spoke01.subnet_name
  nsg_id               = module.spoke01.nsg_id
  name                 = "vm-01"
  username             = var.username
  password             = var.password
}

module "hub-to-spoke01-peering" {
  source = "./modules/vnet-peering"

  spoke_name = module.spoke01.name
  spoke_virtual_network = module.spoke01.virtual_network
}
