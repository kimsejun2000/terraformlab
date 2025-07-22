variable "name" { type = string }
variable "location" { type = string }
variable "ip_cidr" {
  type        = string
  description = "IP CIDR for the spoke module"
}

locals {
  resource_tags = {
    Name = var.name
  }
}