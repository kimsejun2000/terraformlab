terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
  type    = string
  description = "Base on resource names"
}

variable "ec2_resource_type" {
  type    = string
  default = "t2.micro"
  description = "Base on resource type"
}

variable "ec2_ami_id" {
  type    = string
  default = "ami-062cf18d655c0b1e8"
  description = "Image ID to be connected to"
}

variable "subnet_id" {
    type = string
    description = "Subnet ID to be connected to"
}

variable "security_group_id" {
    type = string
    description = "SG ID to be connected to"
}

locals {
  resource_tags = {
    Name = var.name
  }
}

resource "aws_network_interface" "my_eni" {
  subnet_id   = var.subnet_id
  security_groups = [var.security_group_id]
  

  tags = local.resource_tags
}

resource "aws_instance" "my_instance" {
  ami           = var.ec2_ami_id
  instance_type = var.ec2_resource_type

  network_interface {
    network_interface_id = aws_network_interface.my_eni.id
    device_index         = 0
  }

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y apache2
service apache2 start
service apache2 restart
EOF

  tags = local.resource_tags
}

resource "aws_eip" "my_eip" {
  instance = aws_instance.my_instance.id
  domain   = "vpc"

  tags = local.resource_tags
}

output "public_ip" {
  value = aws_eip.my_eip.public_ip
}