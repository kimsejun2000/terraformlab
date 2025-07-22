provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "hub"
  features {}
  subscription_id = "<Hub Subscription ID>"
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
