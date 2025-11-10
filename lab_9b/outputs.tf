output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "container_fqdn" {
  description = "The Fully Qualified Domain Name of the container instance"
  value       = azurerm_container_group.aci.fqdn
}

output "container_ip_address" {
  description = "The public IP address of the container instance"
  value       = azurerm_container_group.aci.ip_address
}