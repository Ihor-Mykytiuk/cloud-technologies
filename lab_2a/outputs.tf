output "management_group_id" {
  description = "ID of the created Management Group"
  value       = azurerm_management_group.az104_mg1.id
}

output "helpdesk_group_object_id" {
  description = "Object ID of the created 'helpdesk' group"
  value       = azuread_group.helpdesk.object_id
}

output "vm_contributor_role_assignment_id" {
  description = "ID of the VM Contributor role assignment"
  value       = azurerm_role_assignment.vm_contributor_assignment.id
}

output "custom_role_definition_id" {
  description = "ID of the custom role definition"
  value       = azurerm_role_definition.custom_support_request.id
}

output "custom_role_definition_name" {
  description = "Name of the custom role definition"
  value       = azurerm_role_definition.custom_support_request.name
}

output "custom_role_definition_permissions" {
  description = "Permissions of the custom role definition"
  value       = azurerm_role_definition.custom_support_request.permissions
}

output "custom_role_definition_assignable_scopes" {
  description = "Assignable scopes of the custom role definition"
  value       = azurerm_role_definition.custom_support_request.assignable_scopes
}