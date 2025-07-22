output "subnet" {
  value = azurerm_subnet.main
}

output "vpn_subnet" {
  value = azurerm_subnet.vpn_gateway
}

output "firewall_subnet" {
  value = azurerm_subnet.firewall_subnet
}

output "bastion_ip" {
  value = azurerm_public_ip.bastion_ip.ip_address
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "nsg_id" {
  value = azurerm_network_security_group.main.id
}
