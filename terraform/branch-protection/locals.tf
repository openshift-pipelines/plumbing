locals {
  config = yamldecode(file("${path.module}/../../config/repos.yaml"))

  # All repository names from the config
  all_repos = keys(local.config.repos)

  # Map of repo -> default branch name
  default_branches = {
    for repo, cfg in local.config.repos :
    repo => cfg.default_branch
  }

  # Map of repo -> list of required status check contexts (from flat "checks" field)
  repo_checks = {
    for repo, cfg in local.config.repos :
    repo => cfg.checks
  }

  # Map of repo -> required approving review count (per-repo override or global default)
  repo_required_approving_review_count = {
    for repo, cfg in local.config.repos :
    repo => lookup(cfg, "required_approving_review_count", var.required_approving_review_count)
  }

  # ---------------------------------------------------------------------------
  # Ruleset locals
  # ---------------------------------------------------------------------------

  # Per-repo ruleset overrides (empty map if not specified)
  repo_ruleset = {
    for repo, cfg in local.config.repos :
    repo => lookup(cfg, "ruleset", {})
  }

  # Branch patterns for each repo's ruleset
  # Always include ~DEFAULT_BRANCH and release-*, plus any extra branches
  repo_ruleset_branches = {
    for repo, cfg in local.config.repos :
    repo => distinct(concat(
      ["~DEFAULT_BRANCH", "refs/heads/release-*"],
      lookup(lookup(cfg, "ruleset", {}), "branches", [])
    ))
  }

  # Status checks: merge flat "checks" field with ruleset.status_checks
  # The flat "checks" field has no integration_id; ruleset.status_checks can specify one
  repo_ruleset_status_checks = {
    for repo, cfg in local.config.repos :
    repo => concat(
      # From flat checks field (no integration_id)
      [for ctx in cfg.checks : { context = ctx, integration_id = null }],
      # From ruleset.status_checks (with optional integration_id)
      lookup(lookup(cfg, "ruleset", {}), "status_checks", [])
    )
  }

  # Allowed merge methods (default: all methods allowed)
  repo_allowed_merge_methods = {
    for repo, cfg in local.config.repos :
    repo => lookup(lookup(cfg, "ruleset", {}), "allowed_merge_methods", [])
  }

  # Linear history
  repo_required_linear_history = {
    for repo, cfg in local.config.repos :
    repo => lookup(lookup(cfg, "ruleset", {}), "required_linear_history", false)
  }

  # Code owner review
  repo_require_code_owner_review = {
    for repo, cfg in local.config.repos :
    repo => lookup(lookup(cfg, "ruleset", {}), "require_code_owner_review", false)
  }

  # Copilot code review
  repo_copilot_code_review = {
    for repo, cfg in local.config.repos :
    repo => lookup(lookup(cfg, "ruleset", {}), "copilot_code_review", false)
  }

  # Merge queue config (null if not set)
  repo_merge_queue = {
    for repo, cfg in local.config.repos :
    repo => lookup(lookup(cfg, "ruleset", {}), "merge_queue", null)
  }

  # No branch creation (for release-tests style repos)
  repo_no_branch_creation = {
    for repo, cfg in local.config.repos :
    repo => lookup(lookup(cfg, "ruleset", {}), "no_branch_creation", false)
  }

}
