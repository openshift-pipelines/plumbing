locals {
  config = yamldecode(file("${path.module}/../../config/repos.yaml"))

  # All repository names from the config
  all_repos = keys(local.config.repos)

  # Map of repo -> default branch name
  default_branches = {
    for repo, cfg in local.config.repos :
    repo => cfg.default_branch
  }

  # Map of repo -> list of required status check contexts
  repo_checks = {
    for repo, cfg in local.config.repos :
    repo => cfg.checks
  }

  # Map of repo -> required approving review count (per-repo override or global default)
  repo_required_approving_review_count = {
    for repo, cfg in local.config.repos :
    repo => lookup(cfg, "required_approving_review_count", var.required_approving_review_count)
  }
}
