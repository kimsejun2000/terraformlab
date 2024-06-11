terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = "ap-northeast-2"
    profile = "sejun"
}

locals {
  resource_tags = {
    Name = "sejun"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = local.resource_tags
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = local.resource_tags
}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = local.resource_tags
}

resource "aws_default_route_table" "my_rt" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }

  tags = local.resource_tags
}

resource "aws_security_group" "my_sg" {
  name        = "my_sg"
  description = "Allow HTTP and SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.resource_tags
}

resource "aws_network_interface" "my_eni" {
  subnet_id   = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.my_sg.id]
  

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