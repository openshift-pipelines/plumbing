# -----------------------------------------------------------------
# Look up repo node IDs so imported state matches config
# -----------------------------------------------------------------
data "github_repository" "repos" {
  for_each = toset(local.all_repos)
  name     = each.key
}

# -----------------------------------------------------------------
# Default-branch protection for every repo in config/repos.yaml
# -----------------------------------------------------------------
resource "github_branch_protection" "default" {
  for_each = toset(local.all_repos)

  repository_id = data.github_repository.repos[each.key].node_id
  pattern       = local.default_branches[each.key]

  enforce_admins                  = var.enforce_admins
  require_signed_commits          = var.require_signed_commits
  required_linear_history         = var.required_linear_history
  allows_deletions                = var.allow_deletions
  allows_force_pushes             = var.allow_force_pushes
  require_conversation_resolution = var.require_conversation_resolution

  # Only add required_status_checks block when there are checks configured
  dynamic "required_status_checks" {
    for_each = length(local.repo_checks[each.key]) > 0 ? [1] : []
    content {
      strict   = false
      contexts = local.repo_checks[each.key]
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = local.repo_required_approving_review_count[each.key] > 0 ? [1] : []
    content {
      dismiss_stale_reviews           = var.dismiss_stale_reviews
      require_code_owner_reviews      = var.require_code_owner_reviews
      required_approving_review_count = local.repo_required_approving_review_count[each.key]
    }
  }
}

# -----------------------------------------------------------------
# Release-branch protection (release-* pattern) for every repo
# -----------------------------------------------------------------
resource "github_branch_protection" "releases" {
  for_each = toset(local.all_repos)

  repository_id = data.github_repository.repos[each.key].node_id
  pattern       = "release-*"

  enforce_admins          = false
  require_signed_commits  = var.require_signed_commits
  required_linear_history = var.required_linear_history
  allows_deletions        = false
  allows_force_pushes     = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = var.dismiss_stale_reviews
    require_code_owner_reviews      = var.require_code_owner_reviews
    required_approving_review_count = var.release_required_approving_review_count
  }
}
