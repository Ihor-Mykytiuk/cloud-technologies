resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# 3. App Service Plan (Task 1)
resource "azurerm_service_plan" "plan" {
  name                = "az104-09a-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1" 
}

# 4. Web App - Production (Task 1)
resource "azurerm_linux_web_app" "webapp" {
  name                = "az104-09a-webapp-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.plan.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      php_version = "8.2"
    }
  }
}

# 5. Staging Slot (Task 2)
resource "azurerm_linux_web_app_slot" "staging_slot" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.webapp.id

  site_config {
    application_stack {
      php_version = "8.2"
    }
  }
}

resource "azurerm_app_service_source_control_slot" "staging_source" {
  slot_id  = azurerm_linux_web_app_slot.staging_slot.id
  repo_url = "https://github.com/Azure-Samples/php-docs-hello-world"
  branch   = "master"
  
  use_manual_integration = true
}

resource "azurerm_web_app_active_slot" "swap" {
  slot_id = azurerm_linux_web_app_slot.staging_slot.id
  
  depends_on = [azurerm_app_service_source_control_slot.staging_source]
}

# Task 5: Configure Autoscaling
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "az104-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_service_plan.plan.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 20
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}