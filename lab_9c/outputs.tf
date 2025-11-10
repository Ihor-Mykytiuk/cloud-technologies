output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "container_app_url" {
  description = "The FQDN of the Container App"
  value       = "https://${azurerm_container_app.ca.latest_revision_fqdn}"
}