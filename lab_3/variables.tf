variable "resource_group_name" {
  description = "Name for the resource group"
  type        = string
  default     = "az104-rg3"
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "managed_disks" {
  description = "A map of managed disks to create"
  type = map(object({
    name = string
    size = number
    sku  = string
  }))
}