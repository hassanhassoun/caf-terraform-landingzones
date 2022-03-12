output "objects" {
  value = tomap(
    {
      "data" = {
        "vnets" = try(module.data_virtual_networks, {})
      }
    }
  )
  sensitive = true
}
