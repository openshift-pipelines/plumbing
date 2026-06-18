output "protected_repos" {
  description = "List of repositories with protection applied"
  value       = local.all_repos
}

output "default_branch_protections" {
  description = "Default-branch protection resource IDs (legacy — will be removed)"
  value = {
    for repo in local.all_repos :
    repo => github_branch_protection.default[repo].id
  }
}

output "release_branch_protections" {
  description = "Release-branch protection resource IDs (legacy — will be removed)"
  value = {
    for repo in local.all_repos :
    repo => github_branch_protection.releases[repo].id
  }
}

output "rulesets" {
  description = "Repository ruleset IDs"
  value = {
    for repo in local.all_repos :
    repo => github_repository_ruleset.default[repo].ruleset_id
  }
}
