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
  source = "./module/common"

  name = "${var.name}_common"
}

variable "rds_password" {
  type        = string
  sensitive   = true
  description = "This is a RDS password."
}

locals {
  resource_tags = {
    Name = var.name
  }
}

# EC2 instance에 연결할 Role 생성을 위해 IAM Policy 검색
data "aws_iam_policy" "administratoraccess" {
  name = "AdministratorAccess"
}

# EC2 instance에 연결할 Role 생성
resource "aws_iam_role" "ec2_role" {
  name = "${var.name}_ec2_role_administratoraccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.administratoraccess.arn]

  tags = local.resource_tags
}

# EC2 instance에 연결할 Role을 이용하여 EX2 profile 생성
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}_ec2_profile"
  role = aws_iam_role.ec2_role.name

  tags = local.resource_tags
}

# RDS Instance 생성 시 생성될 subnet 지정을 위한 RDS Subnet Group 생성
resource "aws_db_subnet_group" "my_rds_subnetgroup" {
  name       = "${var.name}_rds_group"
  subnet_ids = [module.common.first_subnet_id,module.common.second_subnet_id]

  tags = local.resource_tags
}

# mysql 8.0 RDS instance 생성
resource "aws_db_instance" "my_rds" {
  identifier           = "${var.name}-rds"
  allocated_storage    = 10
  db_name              = "wordpress"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  availability_zone    = module.common.first_subnet_az
  username             = "wordpress"
  password             = var.rds_password
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.my_rds_subnetgroup.name
  vpc_security_group_ids = [module.common.security_group_id]
  skip_final_snapshot  = true

  tags = local.resource_tags
}

module "instance" {
  source = "./module/create_ec2"

  subnet_id = module.common.first_subnet_id
  security_group_id = module.common.security_group_id
  ec2_profile = aws_iam_instance_profile.ec2_profile.name   # 생성된 EC2 profile 전달
  rds_instance = aws_db_instance.my_rds                     # 생성된 RDS object 전달
  rds_password = var.rds_password
  name = "${var.name}_instance"
}

output "instance1_public_ip" {
  value = module.instance.public_ip
}
