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

module "instances" {
    source = "./module/create_ec2"
    count = 12

    subnet_id = module.common.subnet_ids[count.index % length(module.common.subnet_ids)]
    security_group_id = module.common.security_group_id
    name = count.index > 9 ? "${var.name}_${count.index}" : "${var.name}_0${count.index}"
}

output "instance_public_ips" {
    value = module.instances[*].public_ip
}

output "security_group_id" {
    value = module.common.security_group_id
}
