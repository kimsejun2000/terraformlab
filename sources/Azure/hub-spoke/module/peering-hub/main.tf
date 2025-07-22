provider "azurerm" {
  features {}
  subscription_id = "<hub_subscription_id>"

  alias = "hub"
}

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  provider = azurerm.hub

  name                      = "hub-to-${var.spoke_name}"
  resource_group_name       = var.hub_virtual_network.resource_group_name
  virtual_network_name      = var.hub_virtual_network.name
  remote_virtual_network_id = var.spoke_virtual_network.id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                      = "${var.spoke_name}-to-hub"
  resource_group_name       = var.spoke_virtual_network.resource_group_name
  virtual_network_name      = var.spoke_virtual_network.name
  remote_virtual_network_id = var.hub_virtual_network.id
}