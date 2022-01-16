data "azurerm_storage_account" "remote_data" {
  for_each = try(var.remote_data.storage_accounts, {})
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
