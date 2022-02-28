data "azuredevops_git_repositories" "repos" {
  project_id = data.azuredevops_project.project.id
}


locals {
  repositories = zipmap(tolist(data.azuredevops_git_repositories.repos.repositories.*.name), tolist(data.azuredevops_git_repositories.repos.repositories))
}

resource "azuredevops_build_definition" "build_definition" {

  for_each   = try(var.azure_devops.pipelines, {})
  project_id = data.azuredevops_project.project.id
  name       = each.value.name
  path       = each.value.folder

  variable_groups = lookup(each.value, "variable_group_keys", null) == null ? null : [
    for key in each.value.variable_group_keys :
    azuredevops_variable_group.variable_group[key].id
  ]

  repository {
    repo_id     = local.repositories[each.value.git_repo_name].id
    repo_type   = each.value.repo_type
    yml_path    = each.value.yaml
    branch_name = lookup(each.value, "branch_name", null)
    # service_connection_id = lookup(each.value, "repo_type", null) == "github" ? null : azuredevops_serviceendpoint_azurerm.github[each.value.service_connection_key].id
  }

  ci_trigger {
    use_yaml = null
    override {
        batch  = try(each.value.override.batch, false)
        max_concurrent_builds_per_branch  = try(each.value.override.max_concurrent_builds_per_branch, 1)
        polling_interval  = try(each.value.override.polling_interval, 0)
        dynamic "branch_filter" {
          for_each = try(each.value.override.branch_filter, {})
          content {
            include  = try(branch_filter.value.include, [])
            exclude  = try(branch_filter.value.exclude, [])
          }
        }
        dynamic "path_filter" {
          for_each = try(each.value.override.path_filter, {})
          content {
            include  = try(path_filter.value.include, [])
            exclude  = try(path_filter.value.exclude, [])
          }
        }
    }
  }

  dynamic "variable" {
    for_each = try(each.value.variables, {})

    content {
      name  = variable.key
      value = variable.value
    }
  }

}
