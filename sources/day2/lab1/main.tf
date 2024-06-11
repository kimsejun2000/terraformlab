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
    profile = "sejun"
}

variable "subnet_id" {
    type = string
}

locals {
    resource_tags = {
        Name = "sejun2"
    }
}

data "aws_subnet" "my_subnet" {
    id = var.subnet_id
}

resource "aws_network_interface" "my_eni" {
  subnet_id     = data.aws_subnet.my_subnet.id

  tags          = local.resource_tags
}