variable "spoke_name" {
  type = string
}

variable "spoke_virtual_network" {
  type = object({
    name                = string
    id                  = string
    resource_group_name = string
  })
}