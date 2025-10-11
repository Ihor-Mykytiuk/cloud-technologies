variable "resource_group_name" {
  description = "Name of the main resource group for the lab"
  type        = string
  default     = "az104-rg5"

}

variable "location" {
  description = "The Azure region where all resources will be deployed"
  type        = string
  default     = "East US"
}