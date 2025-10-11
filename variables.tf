variable "resource_group_name" {
  description = "Name of the main resource group for the lab"
  type        = string
  default     = "az104-rg4"

}

variable "location" {
  description = "The Azure region where all resources will be deployed"
  type        = string
  default     = "East US"
}

variable "virtual_networks" {
  description = "A map of virtual networks to create"
  type = map(object({
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
    }))
  }))
}