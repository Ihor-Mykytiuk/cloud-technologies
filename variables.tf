variable "resource_group_name" {
  description = "Name for the resource group"
  type        = string
  default     = "az104-rg2"
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    "Cost Center" = "000"
  }
}
