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

variable "bucket_id" {
    description = "The ID of the bucket"
}

resource "random_string" "tail_string" {
  length    = 6
  upper     = false
  special   = false
}

locals {
  bucket_name = substr("${var.bucket_id}${random_string.tail_string.result}", 0, 64)
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = local.bucket_name
}

resource "aws_dynamodb_table" "my_table" {
  name           = local.bucket_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

output "my_bucket_name" {
  value = aws_s3_bucket.my_bucket.id
}
