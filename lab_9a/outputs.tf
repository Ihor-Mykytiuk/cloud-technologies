output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "webapp_name" {
  description = "The name of the created Web App"
  value       = azurerm_linux_web_app.webapp.name
}

output "webapp_url" {
  description = "The default URL of the created Web App"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}

output "staging_url" {
  description = "The URL of the Staging slot"
  value       = "https://${azurerm_linux_web_app_slot.staging_slot.default_hostname}"
}