terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.profile
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
  description = "Base Region"
}

variable "profile" {
  type        = string
  default     = "default"
  description = "Base profile"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../lab4/terraform.tfstate"
  }
}

data "aws_security_group" "my_sg" {
  id = data.terraform_remote_state.vpc.outputs.security_group_id
}

import {
  to = aws_security_group.my_sg
  id = data.aws_security_group.my_sg.id
}

output "data_sg" {
  value = data.aws_security_group.my_sg
}

resource "aws_security_group" "my_sg" {
  name        = data.aws_security_group.my_sg.name
  description = data.aws_security_group.my_sg.description
  vpc_id      = data.aws_security_group.my_sg.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port = 443
    to_port = 443
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

  tags = data.aws_security_group.my_sg.tags
}
