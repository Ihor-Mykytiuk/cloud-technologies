resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "az104-06-vnet1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.60.0.0/22"]
}

resource "azurerm_subnet" "subnet0" {
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.0.0/24"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "az104-06-nsg1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic0" {
  name                = "az104-06-nic0"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic0_assoc" {
  network_interface_id      = azurerm_network_interface.nic0.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm0" {
  name                  = "az104-06-vm0"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic0.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm0_ext" {
  name                       = "az104-06-vm0-CustomScriptExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm0.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value ('Hello World from ' + $env:computername)"
  })
}

resource "azurerm_network_interface" "nic1" {
  name                = "az104-06-nic1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic1_assoc" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                  = "az104-06-vm1"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm1_ext" {
  name                       = "az104-06-vm1-CustomScriptExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value ('Hello World from ' + $env:computername) && powershell.exe New-Item -Path 'c:\\inetpub\\wwwroot' -Name 'image' -Itemtype 'Directory' && powershell.exe New-Item -Path 'c:\\inetpub\\wwwroot\\image\\' -Name 'iisstart.htm' -ItemType 'file' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\image\\iisstart.htm' -Value ('Image from: ' + $env:computername)"
  })
}

resource "azurerm_network_interface" "nic2" {
  name                = "az104-06-nic2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nic2_assoc" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm2" {
  name                  = "az104-06-vm2"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic2.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm2_ext" {
  name                       = "az104-06-vm2-CustomScriptExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm2.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    commandToExecute = "powershell.exe Install-WindowsFeature -name Web-Server && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value ('Hello World from ' + $env:computername) && powershell.exe New-Item -Path 'c:\\inetpub\\wwwroot' -Name 'video' -Itemtype 'Directory' && powershell.exe New-Item -Path 'c:\\inetpub\\wwwroot\\video\\' -Name 'iisstart.htm' -ItemType 'file' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\video\\iisstart.htm' -Value ('Video from: ' + $env:computername)"
  })
}

resource "azurerm_public_ip" "lb_pip" {
  name                = "az104-lbpip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "az104-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "az104-fe"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "be_pool" {
  name            = "az104-be"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic0_lb_assoc" {
  network_interface_id    = azurerm_network_interface.nic0.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic1_lb_assoc" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.be_pool.id
}

resource "azurerm_lb_probe" "probe" {
  name                = "az104-hp"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = "az104-lbrule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.be_pool.id]
  probe_id                       = azurerm_lb_probe.probe.id
  frontend_ip_configuration_name = "az104-fe"

  load_distribution         = "Default"
  idle_timeout_in_minutes = 4
  tcp_reset_enabled         = false
  floating_ip_enabled       = false
  disable_outbound_snat     = false
}

locals {
  gateway_ip_configuration_name = "az104-gwipc"
  frontend_port_name = "az104-feport"
  frontend_ip_configuration_name = "az104-feipc"
  backend_address_pool_name_default = "az104-appgwbe"
  backend_address_pool_name_image = "az104-imagebe"
  backend_address_pool_name_video = "az104-videobe"
  backend_http_settings_name = "az104-http"
  listener_name = "az104-listener"
  request_routing_rule_name = "az104-gwrule"
  url_path_map_name = "az104-pathmap"
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "subnet-appgw"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.60.3.224/27"]
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "az104-gwpip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "az104-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }


  backend_address_pool {
    name         = local.backend_address_pool_name_default
    ip_addresses = [azurerm_network_interface.nic1.private_ip_address, azurerm_network_interface.nic2.private_ip_address]
  }

  backend_address_pool {
    name         = local.backend_address_pool_name_image
    ip_addresses = [azurerm_network_interface.nic1.private_ip_address]
  }

  backend_address_pool {
    name         = local.backend_address_pool_name_video
    ip_addresses = [azurerm_network_interface.nic2.private_ip_address]
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "PathBasedRouting"
    priority                   = 10
    http_listener_name         = local.listener_name
    url_path_map_name          = local.url_path_map_name
    backend_address_pool_name  = local.backend_address_pool_name_default
    backend_http_settings_name = local.backend_http_settings_name
  }

  url_path_map {
    name                               = local.url_path_map_name
    default_backend_address_pool_name  = local.backend_address_pool_name_default
    default_backend_http_settings_name = local.backend_http_settings_name

    path_rule {
      name                       = "images"
      paths                      = ["/image/*"]
      backend_address_pool_name  = local.backend_address_pool_name_image
      backend_http_settings_name = local.backend_http_settings_name
    }

    path_rule {
      name                       = "videos"
      paths                      = ["/video/*"]
      backend_address_pool_name  = local.backend_address_pool_name_video
      backend_http_settings_name = local.backend_http_settings_name
    }
  }

  depends_on = [
    azurerm_windows_virtual_machine.vm0,
    azurerm_windows_virtual_machine.vm1,
    azurerm_windows_virtual_machine.vm2
  ]
}