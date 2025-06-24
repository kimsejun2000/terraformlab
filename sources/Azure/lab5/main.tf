provider "azurerm" {
  alias = "test"
  features {}
}

variable "location" {
  type        = string
  default     = "koreacentral"
  description = "Azure region"
}

variable "name" {
  type    = string
  default = "sejun"
  description = "Base resource name"
}

module "common" {
  source   = "./module/common"
  name     = "${var.name}_common"
  location = var.location
  providers = {
    azurerm = azurerm.test
  }
}

module "instance1" {
  source               = "./module/create_vm"
  resource_group_name  = module.common.resource_group_name
  virtual_network_name = module.common.virtual_network_name
  subnet_name          = module.common.subnet_name
  nsg_id               = module.common.nsg_id
  name                 = "${var.name}_01"
  location             = var.location
}

module "instance2" {
  source              = "./module/create_vm"
  resource_group_name  = module.common.resource_group_name
  virtual_network_name = module.common.virtual_network_name
  subnet_name          = module.common.subnet_name
  nsg_id              = module.common.nsg_id
  name                = "${var.name}_02"
  location            = var.location
}

output "instance1_public_ip" {
  value = module.instance1.public_ip
}

output "instance2_public_ip" {
  value = module.instance2.public_ip
}
