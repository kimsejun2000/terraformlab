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

output "my_bucket_name" {
  value = aws_s3_bucket.my_bucket.id
}
