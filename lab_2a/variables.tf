variable "management_group_id" {
  description = "ID for the Azure Management Group"
  type        = string
  default     = "az104-mg1"
}

variable "management_group_display_name" {
  description = "Display name for the Azure Management Group"
  type        = string
  default     = "az104-mg1"
}

variable "custom_role_name" {
  description = "Name for the custom role"
  type        = string
  default     = "Custom Support Request"
}