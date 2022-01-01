output "objects" {
  value = tomap(
    { (var.landingzone.key) = merge( {
      for key, value in module.launchpad : key => value
      if try(value, {}) != {}
      },
      { "subscriptions"  =  { for sub in data.azurerm_subscriptions.available.subscriptions : sub.display_name => { ("subscription_id") = replace(sub.id, "/.subscriptions./","") } }})
    }
  )
  sensitive = true
}

output "global_settings" {
  value     = module.launchpad.global_settings
  sensitive = true
}

output "diagnostics" {
  value     = module.launchpad.diagnostics
  sensitive = true
}

output "tfstates" {
  value     = local.tfstates
  sensitive = true
}


output "launchpad_identities" {
  value = var.propagate_launchpad_identities ? {
    (var.landingzone.key) = {
      azuread_groups     = module.launchpad.azuread_groups
      managed_identities = module.launchpad.managed_identities
    }
  } : {}
  sensitive = true
}
