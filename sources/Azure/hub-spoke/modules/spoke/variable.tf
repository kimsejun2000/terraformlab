variable "name" {
  type = string
}

variable "location" {
  type = string
  default = "koreacentral" 
}

variable "ip_address_range" {
  type = string
}

locals {
  name = var.name
  resource_tags = {
    env = local.name
    owner = "serviceteam"
    mangement_group = "app1"
  }
}