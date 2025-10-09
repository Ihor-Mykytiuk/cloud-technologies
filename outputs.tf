output "az104_user1_upn" {
  description = "User Principal Name (UPN) of the internal user"
  value       = azuread_user.az104_user1.user_principal_name
}

output "az104_user1_object_id" {
  description = "Object ID of the internal user"
  value       = azuread_user.az104_user1.object_id
}

output "az104_user1_password" {
  description = "Generated password for the internal user"
  value       = random_password.password.result
  sensitive   = true
}

output "external_user_email" {
  description = "Email address of the invited external user"
  value       = var.external_user_email
}

output "external_user_object_id" {
  description = "Object ID of the invited external user"
  value       = azuread_invitation.external_user.user_id
}

output "it_lab_administrators_group_id" {
  description = "Object ID of the IT Lab Administrators group"
  value       = azuread_group.it_lab_administrators.object_id
}

output "it_lab_administrators_members" {
  description = "List of Object IDs of the members of the IT Lab Administrators group"
  value = [
    azuread_user.az104_user1.object_id,
    azuread_invitation.external_user.user_id
  ]
}
