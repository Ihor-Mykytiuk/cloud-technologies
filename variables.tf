variable "resource_group_name" {
  description = "Name of the main resource group for the lab"
  type        = string
  default     = "az104-rg6"

}

variable "location" {
  description = "The Azure region where all resources will be deployed"
  type        = string
  default     = "West US 2"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  description = "Administrator name for virtual machines"
  type        = string
  default     = "localadmin"
}

variable "admin_password" {
  type        = string
  sensitive   = true
}