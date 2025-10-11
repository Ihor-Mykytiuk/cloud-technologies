output "asg_id" {
  description = "The ID of the Application Security Group."
  value       = azurerm_application_security_group.asg_web.id
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.nsg_secure.id
}