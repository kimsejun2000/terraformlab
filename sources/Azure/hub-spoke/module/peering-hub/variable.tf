variable "spoke_name" { type = string }
variable "hub_virtual_network" { 
  type        = object({
    id      = string,
    name    = string,
    resource_group_name = string
})
}

variable "spoke_virtual_network" { 
  type        = object({
    id      = string,
    name    = string,
    resource_group_name = string
})
}