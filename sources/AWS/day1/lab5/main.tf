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

variable "name" {
  type    = string
  default = "sejun"
  description = "Base on resource names"
}

module "common" {
    source      = "./module/common"

    name        = "${var.name}_common"
}

module "instance1" {
    source = "./module/create_ec2"

    subnet_id = module.common.subnet_id
    security_group_id = module.common.security_group_id
    name = "${var.name}_01"
}

module "instance2" {
    source = "./module/create_ec2"

    subnet_id = module.common.subnet_id
    security_group_id = module.common.security_group_id
    name = "${var.name}_02"
}

output "instance1_public_ip" {
    value = module.instance1.public_ip
}

output "instance2_public_ip" {
    value = module.instance2.public_ip
}