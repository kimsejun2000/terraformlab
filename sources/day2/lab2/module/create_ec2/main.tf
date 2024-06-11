terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "tag_name" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "security_group_id" {
    type = string
}

locals {
  resource_tags = {
    Name = var.tag_name
  }
}

resource "aws_network_interface" "my_eni" {
  subnet_id   = var.subnet_id
  security_groups = [var.security_group_id]
  

  tags = local.resource_tags
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0edc5427d49d09d2a"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.my_eni.id
    device_index         = 0
  }

  user_data = <<-EOF
#!/bin/bash
def update –y && def install -y httpd
systemctl start httpd
EOF

  tags = local.resource_tags
}

resource "aws_eip" "my_eip" {
  instance = aws_instance.my_instance.id
  domain   = "vpc"

  tags = local.resource_tags
}

output "public_ip" {
  value = aws_eip.my_eip.address
}