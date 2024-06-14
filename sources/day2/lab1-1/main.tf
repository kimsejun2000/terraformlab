terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

locals {
  source_tags = {
    Name = "sejun"
  }
  
  resource_tags = {
    Name = "sejun3"
  }
}

data "aws_subnet" "my_subnet" {
  tags = local.source_tags
}

data "aws_security_groups" "my_sg" {
  tags = local.source_tags
}

resource "aws_network_interface" "my_eni" {
  subnet_id     = data.aws_subnet.my_subnet.id
  security_groups = data.aws_security_groups.my_sg.ids

  tags          = local.resource_tags
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