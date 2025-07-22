variable "name" { type = string }
variable "location" { type = string }

locals {
  name = "${var.name}-hub"
  resource_tags = {
    Name = local.name
  }
}