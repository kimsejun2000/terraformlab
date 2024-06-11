provider "aws" {
    region = "ap-northeast-2"
    profile = "sejun"
}

module "common" {
    source = "./module/common"

    tag_name = "common"
}

module "instance1" {
    source = "./module/create_ec2"

    subnet_id = module.common.subnet_id
    security_group_id = module.common.security_group_id
    tag_name = "sejun_day2_01"
}

module "instance2" {
    source = "./module/create_ec2"

    subnet_id = module.common.subnet_id
    security_group_id = module.common.security_group_id
    tag_name = "sejun_day2_02"
}