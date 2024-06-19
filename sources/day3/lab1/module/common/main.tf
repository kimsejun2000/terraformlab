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

locals {
  resource_tags = {
    Name = var.tag_name
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

# RDS Subnet group을 만들기 위해 다른 Availavility Zone(AZ)에 Subnet 추가 생성
resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2c"

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

output "subnet_id" {
  value = aws_subnet.my_subnet.id
}

# 추가로 생성된 subnet id 출력
output "subnet2_id" {
  value = aws_subnet.my_subnet2.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}