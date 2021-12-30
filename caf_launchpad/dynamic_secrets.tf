
module "dynamic_keyvault_secrets" {
  source  = "aztfmod/caf/azurerm//modules/security/dynamic_keyvault_secrets"
  version = "~>5.5.0"

  #source = "git::https://github.com/aztfmod/terraform-azurerm-caf.git//modules/security/dynamic_keyvault_secrets?ref=master"

  for_each = try(var.dynamic_keyvault_secrets, {})

  settings = each.value
  keyvault = module.launchpad.keyvaults[each.key]
  objects  = merge(module.launchpad, 
                   { "subscriptions" =  { for sub in data.azurerm_subscriptions.available.subscriptions : sub.display_name => { ("subscription-id") = sub.subscription_id } }})
}
