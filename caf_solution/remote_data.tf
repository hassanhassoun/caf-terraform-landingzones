data "azurerm_storage_account" "remote_data" {
  for_each = try(var.remote_data.storage_accounts, {})
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

module "data_virtual_networks" {
  for_each = try(var.remote_data.virtual_networks, {})
  source  = "./data/virtual_networks"
  virtual_network_name = each.value.name 
  resource_group_name = each.value.resource_group_name
}


output debug {
  value = module.data_virtual_networks.*
}
