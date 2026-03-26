output "protected_repos" {
  description = "List of repositories with branch protection applied"
  value       = local.all_repos
}

output "default_branch_protections" {
  description = "Default-branch protection resource IDs"
  value = {
    for repo in local.all_repos :
    repo => github_branch_protection.default[repo].id
  }
}

output "release_branch_protections" {
  description = "Release-branch protection resource IDs"
  value = {
    for repo in local.all_repos :
    repo => github_branch_protection.releases[repo].id
  }
}
