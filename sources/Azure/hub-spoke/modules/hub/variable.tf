locals {
  name = "hub"
  location = "koreacentral"
  resource_tags = {
    env = local.name
    owner = "platformteam"
    mangement_group = "platform"
  }
}