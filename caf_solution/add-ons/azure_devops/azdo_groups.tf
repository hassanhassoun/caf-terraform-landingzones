data "azuredevops_git_repositories" "all_repos" {
  project_id     = data.azuredevops_project.project.id
}

locals {
  groups = { for k,v in var.groups: k => v if  try(v.git_permissions, {}) != {} }
  group_repo_pairs = flatten([
    for key, value in local.groups: [
      for repo in data.azuredevops_git_repositories.all_repos.repositories: {
        repo_id = repo.id
        group = azuredevops_group.group[key].id
        permissions = value.git_permissions
      }
    ]
  ])
}

resource "azuredevops_group" "group" {
  for_each = var.groups

  scope        = data.azuredevops_project.project.id
  display_name = each.value.display_name
  description  = each.value.description
}

resource "azuredevops_git_permissions" "repo_permissions" {
  for_each = { for group_repo_pair in local.group_repo_pairs: group_repo_pair.repo_id => { group = group_repo_pair.group, permissions = group_repo_pair.permissions } }

  project_id    = data.azuredevops_project.project.id
  repository_id = each.key
  principal     = each.value.group
  permissions   = each.value.permissions
}

# See https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition_permissions#permissions for a list of available permissions.
resource "azuredevops_build_definition_permissions" "permissions" {
  for_each =  { for key, value in try(merge(var.azure_devops.pipelines, var.azure_devops.apply_pipelines), {}):
                key => value.permissions
                if try(value.permissions, null) != null }

  project_id = data.azuredevops_project.project.id
  principal  = azuredevops_group.group[each.value.group_key].id
  build_definition_id = try(azuredevops_build_definition.build_definition[each.key].id, azuredevops_build_definition.apply_build_definition[each.key].id)

  permissions = each.value.permissions
}
