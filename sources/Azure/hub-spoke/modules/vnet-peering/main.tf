resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                      = "hub-to-${var.spoke_name}"
  resource_group_name       = "hub-rg"
  virtual_network_name      = "hub-vnet"
  remote_virtual_network_id = var.spoke_virtual_network.id

  provider = azurerm.hub
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                      = "${var.spoke_name}-to-hub"
  resource_group_name       = var.spoke_virtual_network.resource_group_name
  virtual_network_name      = var.spoke_virtual_network.name
  remote_virtual_network_id = "/subscriptions/71ea60c6-4395-4dae-a375-516f99b1a314/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"
}
