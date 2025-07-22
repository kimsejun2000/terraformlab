output "subnet" {
  value = azurerm_subnet.main
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}
