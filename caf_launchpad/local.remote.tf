locals {
  remote = {
    azuread_service_principals = {
      for key, value in try(var.landingzone.tfstates, {}) : key => merge(try(data.terraform_remote_state.remote[key].outputs.objects[key].azuread_service_principals, {}))
    }
    subscriptions = {
       "seed"  =  { for sub in data.azurerm_subscriptions.available.subscriptions : sub.display_name => { ("id") = sub.id } }
    }
  }
}

data "azurerm_subscriptions" "available" {
}
