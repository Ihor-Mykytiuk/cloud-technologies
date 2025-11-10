resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "vnets" {
  for_each = var.virtual_networks

  source              = "./modules/vnets"
  vnet_name           = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = each.value.address_space
  subnets             = each.value.subnets
}


resource "azurerm_application_security_group" "asg_web" {
  name                = var.asg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "nsg_secure" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowASG"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    destination_address_prefix = "*"
    source_application_security_group_ids = [azurerm_application_security_group.asg_web.id]
  }

  security_rule {
    name                       = "DenyInternetOutbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id = module.vnets[var.nsg_target_vnet_name].subnet_ids[var.nsg_target_subnet_name]
  network_security_group_id = azurerm_network_security_group.nsg_secure.id
}

resource "azurerm_dns_zone" "public_zone" {
  name                = var.public_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "public_records" {
  for_each = var.public_dns_a_records

  name                = each.key
  zone_name           = azurerm_dns_zone.public_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = each.value.ttl
  records             = each.value.records
}

resource "azurerm_private_dns_zone" "private_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = var.private_dns_vnet_link_name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_zone.name
  virtual_network_id    = module.vnets[var.dns_link_target_vnet_name].vnet_id
}

resource "azurerm_private_dns_a_record" "private_records" {
  for_each = var.private_dns_a_records

  name                = each.key
  zone_name           = azurerm_private_dns_zone.private_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = each.value.ttl
  records             = each.value.records
}