output "resource_group_id" {
  description = "The ID of the created resource group."
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "The Name of the created resource group."
  value       = azurerm_resource_group.rg.name
}

output "require_policy_assignment_id" {
  description = "The ID of the 'Require Tag' policy assignment."
  value       = azurerm_resource_group_policy_assignment.require_tag.id
}