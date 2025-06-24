terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "name" {
    type = string
}

variable "vpc_ip_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "first_subnet_ip_cidr" {
    type = string
    default = "10.0.0.0/24"
}

variable "second_subnet_ip_cidr" {
    type = string
    default = "10.0.1.0/24"
}

locals {
  resource_tags = {
    Name = var.name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_ip_cidr

  tags = local.resource_tags
}

resource "aws_subnet" "first_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.first_subnet_ip_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = local.resource_tags
}

# RDS Subnet group을 만들기 위해 다른 Availavility Zone(AZ)에 Subnet 추가 생성
resource "aws_subnet" "second_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.second_subnet_ip_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

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
  name        = "${var.name}_sg"
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

  # MySQL 연결을 위한 ingress 정책 생성
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    self = true     # security group 참조를 자기 자신으로 하기 위한 옵션
    description = "Allow mysql"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.resource_tags
}

output "first_subnet_id" {
  value = aws_subnet.first_subnet.id
}

output "first_subnet_az" {
  value = aws_subnet.first_subnet.availability_zone
}

# 추가로 생성된 subnet id 출력
output "second_subnet_id" {
  value = aws_subnet.second_subnet.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}