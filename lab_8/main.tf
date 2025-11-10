resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# resource "azurerm_virtual_network" "vnet" {
#   name                = "az104-08-vnet"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   address_space       = ["10.80.0.0/16"]
# }
#
# resource "azurerm_subnet" "subnet" {
#   name                 = "default"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.80.1.0/24"]
# }
#
# resource "azurerm_network_interface" "nic1" {
#   name                = "az104-vm1-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#
#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }
#
# resource "azurerm_windows_virtual_machine" "vm1" {
#   name                  = "az104-vm1"
#   resource_group_name   = azurerm_resource_group.rg.name
#   location              = azurerm_resource_group.rg.location
#   zone                  = "1"
#   size                  = "Standard_D2ds_v4"
#   admin_username        = var.admin_username
#   admin_password        = var.admin_password
#   network_interface_ids = [azurerm_network_interface.nic1.id]
#
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }
#
#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
#
#   boot_diagnostics {
#     storage_account_uri = null
#   }
# }
#
# resource "azurerm_network_interface" "nic2" {
#   name                = "az104-vm2-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#
#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }
#
# resource "azurerm_windows_virtual_machine" "vm2" {
#   name                  = "az104-vm2"
#   resource_group_name   = azurerm_resource_group.rg.name
#   location              = azurerm_resource_group.rg.location
#   zone                  = "2"
#   size                  = var.vm_size
#   admin_username        = var.admin_username
#   admin_password        = var.admin_password
#   network_interface_ids = [azurerm_network_interface.nic2.id]
#
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }
#
#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
#
#   boot_diagnostics {
#     storage_account_uri = null
#   }
# }
#
# resource "azurerm_managed_disk" "disk1" {
#   name                 = "vm1-disk1"
#   location             = azurerm_resource_group.rg.location
#   resource_group_name  = azurerm_resource_group.rg.name
#   storage_account_type = "StandardSSD_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = 32
#   zone                 = "1"
# }
#
# resource "azurerm_virtual_machine_data_disk_attachment" "disk1_attachment" {
#   managed_disk_id    = azurerm_managed_disk.disk1.id
#   virtual_machine_id = azurerm_windows_virtual_machine.vm1.id
#   lun                = "10"
#   caching            = "ReadWrite"
# }

locals {
  vmss_vnet_name         = "vmss-vnet"
  vmss_subnet_name       = "subnet0"
  vmss_nsg_name          = "vmss1-nsg"
  vmss_nsg_sec_rule_name = "allow-http"
  vmss_lb_pip_name       = "vmss-lb-pip"
  vmss_lb_name           = "vmss-lb"
  vmss_lb_fe_name        = "vmss-lb-fe"
  vmss_be_pool_name      = "vmss-lb-be"
  vmss_probe_name        = "vmss-lb-probe"
  vmss_lb_rule_name      = "vmss-lb-rule"
  vmss_vmss_name         = "vmss1"
  vmss_nic_name          = "vmss-nic"
  vmss_ip_config_name    = "internal"
}

resource "azurerm_virtual_network" "vmss_vnet" {
  name                = local.vmss_vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.82.0.0/20"]
}

resource "azurerm_subnet" "vmss_subnet" {
  name                 = local.vmss_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vmss_vnet.name
  address_prefixes     = ["10.82.0.0/24"]
}

resource "azurerm_network_security_group" "vmss_nsg" {
  name                = local.vmss_nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = local.vmss_nsg_sec_rule_name
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vmss_lb_pip" {
  name                = local.vmss_lb_pip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "vmss_lb" {
  name                = local.vmss_lb_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = local.vmss_lb_fe_name
    public_ip_address_id = azurerm_public_ip.vmss_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "vmss_be_pool" {
  name            = local.vmss_be_pool_name
  loadbalancer_id = azurerm_lb.vmss_lb.id
}

resource "azurerm_lb_probe" "vmss_probe" {
  name            = local.vmss_probe_name
  loadbalancer_id = azurerm_lb.vmss_lb.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "vmss_lb_rule" {
  name                           = local.vmss_lb_rule_name
  loadbalancer_id                = azurerm_lb.vmss_lb.id
  frontend_ip_configuration_name = local.vmss_lb_fe_name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss_be_pool.id]
  probe_id                       = azurerm_lb_probe.vmss_probe.id
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                = local.vmss_vmss_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_B1ms"
  instances           = 2
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zones               = ["1", "2", "3"]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = local.vmss_nic_name
    primary = true
    network_security_group_id = azurerm_network_security_group.vmss_nsg.id

    ip_configuration {
      name      = local.vmss_ip_config_name
      primary   = true
      subnet_id = azurerm_subnet.vmss_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss_be_pool.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}


resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "vmss1-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "PercentChangeCount"
        value     = 50
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "PercentChangeCount"
        value     = 50
        cooldown  = "PT5M"
      }
    }
  }
}