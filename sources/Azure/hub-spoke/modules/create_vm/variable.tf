variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_name" { type = string }
variable "subnet_name" { type = string }
variable "nsg_id" { type = string }
variable "username" { type = string }
variable "password" {
  type = string
  sensitive = true  
}
variable "location" { 
  type = string 
  default = "koreacentral"
}

locals {
  name = var.name
  resource_tags = {
    env = local.name
    owner = "serviceteam"
    mangement_group = "app1"
  }
}

data "azurerm_subnet" "main" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}
