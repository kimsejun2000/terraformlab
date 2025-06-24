terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "virtual_network_name" { type = string }
variable "subnet_name" { type = string }
variable "nsg_id" { type = string }
variable "location" { type = string }

locals {
  resource_tags = {
    Name = var.name
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.name}-pip"
  location            = var.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "main" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
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
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.main.id]

  admin_password = "P@ssw0rd1234!" # For demo only; use SSH keys in production

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
}

output "public_ip" {
  value = azurerm_public_ip.main.ip_address
}