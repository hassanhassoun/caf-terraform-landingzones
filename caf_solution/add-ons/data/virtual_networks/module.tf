variable resource_group_name {}
variable virtual_network_name {}

data "azurerm_virtual_network" "vnet" {
  name                 = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_subnet" "subnet" {
  for_each = { for subnet in data.azurerm_virtual_network.vnet.subnets: subnet => { name = subnet } }
  name                 = each.key
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

output "id" {
  value       = data.azurerm_virtual_network.vnet.id
  description = "Virutal Network id"
}

output "name" {
  value       = data.azurerm_virtual_network.vnet.name
  description = "Virutal Network name"
}

output "address_space" {
  value       = data.azurerm_virtual_network.vnet.address_space
  description = "Virutal Network address_space"
}

output "dns_servers" {
  value       = data.azurerm_virtual_network.vnet.dns_servers
  description = "Virutal Network dns_servers"
}

output "resource_group_name" {
  value       = data.azurerm_virtual_network.vnet.resource_group_name
  description = "Virutal Network resource_group_name"

}

output "location" {
  value       = data.azurerm_virtual_network.vnet.location
  description = "Azure region of the virtual network"
}

output "subnets" {
  description = "Returns all the subnets objects in the Virtual Network. As a map of keys, ID"
  value       =  data.azurerm_subnet.subnet
}
