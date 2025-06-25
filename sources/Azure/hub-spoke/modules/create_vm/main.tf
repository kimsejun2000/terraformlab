resource "azurerm_public_ip" "main" {
  name                = "${var.name}-pip"
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  resource_group_name = var.resource_group_name

  tags = local.resource_tags
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = local.resource_tags
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v4"
  admin_username      = var.username

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_password = var.password # For demo only; use SSH keys in production
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.name}-osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2
    systemctl enable apache2
    systemctl start apache2
  EOF
  )

  tags = local.resource_tags
}
