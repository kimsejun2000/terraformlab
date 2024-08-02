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

variable "ec2_resource_type" {
  type    = string
  default = "t2.micro"
  description = "Base on resource type"
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

# EC2 profile 연결을 위한 변수 추가 선언
variable "ec2_profile" {
  type = string
}

# wordpress에 RDS 정보 입력을 위한 변수 추가 선언
variable "rds_instance" {
  type = object({
    address = string
    db_name = string
    username = string
  })
}

# wordpress에 RDS 비밀번호를 입력을 위한 변수 추가 선언
variable "rds_password" {
  type = string
}

locals {
  resource_tags = {
    Name = var.name
  }
}

# ubuntu 20.04 이미지 검색
data "aws_ami" "ubuntu_20_04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*20.04*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_network_interface" "my_eni" {
  subnet_id   = var.subnet_id
  security_groups = [var.security_group_id]
  

  tags = local.resource_tags
}

resource "aws_instance" "my_instance" {
  ami           = data.aws_ami.ubuntu_20_04.image_id    # 검색된 AMI 연결
  instance_type = var.ec2_resource_type

  network_interface {
    network_interface_id = aws_network_interface.my_eni.id
    device_index         = 0
  }

  iam_instance_profile = var.ec2_profile                # system manager 실행을 위한 EC2 profile 연결

  # Wordpress 설치 script (script 내 variable 참조)
  user_data = <<-EOF
#!/bin/bash

# Wordpress 초기화
apt update -y
apt install -y apache2 php php-curl php-gd php-mbstring php-xml php-xmlrpc libapache2-mod-php php-mysql php-fpm php-json php-cgi php-soap php-intl php-zip
sed -i -e '169a\\<Directory /var/www/html/>' /etc/apache2/apache2.conf
sed -i -e '170a\\    AllowOverride All' /etc/apache2/apache2.conf
sed -i -e '171a\\</Directory>' /etc/apache2/apache2.conf
sed -i -e '172a\\' /etc/apache2/apache2.conf
a2enmod rewrite
apache2ctl configtest

# Wordpress 다운로드 및 설정
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
touch /tmp/wordpress/.htaccess
chmod 660 /tmp/wordpress/.htaccess
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade

sed -i -e '83a\\' /tmp/wordpress/wp-config.php
sed -i -e '84a\\define("FS_METHOD", "direct");' /tmp/wordpress/wp-config.php
sed -i -e '85a\\define("WP_HOME", "http://". filter_input(INPUT_SERVER, "HTTP_HOST", FILTER_SANITIZE_STRING));' /tmp/wordpress/wp-config.php
sed -i -e '86a\\define("WP_SITEURL", "http://". filter_input(INPUT_SERVER, "HTTP_HOST", FILTER_SANITIZE_STRING));' /tmp/wordpress/wp-config.php
sed -i -e '87a\\define("WP_CONTENT_URL", "/wp-content");' /tmp/wordpress/wp-config.php
sed -i -e '88a\\define("DOMAIN_CURRENT_SITE", filter_input(INPUT_SERVER, "HTTP_HOST", FILTER_SANITIZE_STRING));' /tmp/wordpress/wp-config.php
sed -i -e '89a\\' /tmp/wordpress/wp-config.php
sed -i -e '90a\\' /tmp/wordpress/wp-config.php

sed -i -e 's/database_name_here/${var.rds_instance.db_name}/g' /tmp/wordpress/wp-config.php
sed -i -e 's/username_here/${var.rds_instance.username}/g' /tmp/wordpress/wp-config.php
sed -i -e 's/password_here/${var.rds_password}/g' /tmp/wordpress/wp-config.php
sed -i -e 's/localhost/${var.rds_instance.address}/g' /tmp/wordpress/wp-config.php

# Wordpress 복사
rm -rf /var/www/html
sudo cp -a /tmp/wordpress/. /var/www/html

chown -R www-data:www-data /var/www/html
chmod -R g+w /var/www/html

# Apache service restart
service apache2 restart
EOF

  tags = local.resource_tags
}

resource "aws_eip" "my_eip" {
  instance = aws_instance.my_instance.id
  domain   = "vpc"

  tags = local.resource_tags
}

output "public_ip" {
  value = aws_eip.my_eip.public_ip
}