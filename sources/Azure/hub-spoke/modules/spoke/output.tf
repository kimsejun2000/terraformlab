output "name" {
  value = var.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "virtual_network" {
  value = azurerm_virtual_network.vnet
}

output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}
