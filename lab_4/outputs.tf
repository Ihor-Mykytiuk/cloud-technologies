output "asg_id" {
  description = "The ID of the Application Security Group."
  value       = azurerm_application_security_group.asg_web.id
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.nsg_secure.id
}

output "public_dns_zone_name_servers" {
  description = "Name servers for the public DNS zone. Use one of these for the 'nslookup' command."
  value       = azurerm_dns_zone.public_zone.name_servers
}