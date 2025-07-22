provider "azurerm" {
  features {}
}


variable "location" {
  type        = string
  default     = "koreacentral"
  description = "Azure region"
}

variable "name" {
  type    = string
  description = "Base resource name"
}

module "hub" {
  source   = "./module/hub"
  name     = var.name
  location = var.location
}

module "spoke1" {
  source   = "./module/spoke"
  name     = "${var.name}-spoke1"
  location = var.location
  ip_cidr  = "10.1.0.0/16"
}

module "spoke2" {
  source   = "./module/spoke"
  name     = "${var.name}-spoke2"
  location = var.location
  ip_cidr  = "10.2.0.0/16"
}

module "hubtospoke1" {
  source   = "./module/peering-hub"

  spoke_name = "${var.name}-spoke1"
  hub_virtual_network = module.hub.virtual_network
  spoke_virtual_network = module.spoke1.virtual_network
}

module "hubtospoke2" {
  source   = "./module/peering-hub"

  spoke_name = "${var.name}-spoke2"
  hub_virtual_network = module.hub.virtual_network
  spoke_virtual_network = module.spoke2.virtual_network
}