output "bastion_ip" {
  value = azurerm_public_ip.bastion_ip.ip_address
}

output "virtual_network" {
  value = azurerm_virtual_network.main
}
