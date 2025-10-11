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

variable "asg_name" {
  description = "Name for the Application Security Group"
  type        = string
  default     = "asg-web"
}

variable "nsg_name" {
  description = "Name for the Network Security Group"
  type        = string
  default     = "myNSGSecure"
}

variable "nsg_target_vnet_name" {
  description = "The name of the VNet to associate the NSG with."
  type        = string
  default     = "CoreServicesVnet"
}

variable "nsg_target_subnet_name" {
  description = "The name of the Subnet to associate the NSG with."
  type        = string
  default     = "SharedServicesSubnet"
}
