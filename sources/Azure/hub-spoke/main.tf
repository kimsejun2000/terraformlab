provider "azurerm" {
  features {}
}

provider "azurerm" {
    alias = "hub"
  features {}
  subscription_id = "70cae3b9-cda4-4d2e-ab79-6a354bfe1dc9"
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
