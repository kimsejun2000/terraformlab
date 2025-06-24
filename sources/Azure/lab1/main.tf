terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = "lab1-rg"
}

variable "location" {
  type        = string
  default     = "koreacentral"
  description = "Azure region"
}

variable "storage_account_name" {
  description = "The ID of the storage account"
  default     = "lab1st"
}

resource "random_string" "tail_string" {
  length  = 6
  upper   = false
  special = false
}

locals {
  storage_account_name = lower(substr("${var.storage_account_name}${random_string.tail_string.result}", 0, 24))
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "main" {
  name                  = "mycontainer"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "storage_container_name" {
  value = azurerm_storage_container.main.name
}
