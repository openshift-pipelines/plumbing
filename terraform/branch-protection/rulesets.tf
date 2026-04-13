# -----------------------------------------------------------------
# Repository rulesets for every repo in config/repos.yaml
#
# Replaces github_branch_protection with the newer rulesets API.
# Each repo gets a single "default" ruleset covering default branch
# and release branches, with per-repo overrides from config.
# -----------------------------------------------------------------

resource "github_repository_ruleset" "default" {
  for_each = toset(local.all_repos)

  name        = "default"
  repository  = each.key
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = local.repo_ruleset_branches[each.key]
      exclude = []
    }
  }

  # Org admins can bypass
  bypass_actors {
    actor_id    = 0
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  # Repo admins can bypass
  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    # -- Always enabled --
    deletion         = true
    non_fast_forward = true

    # -- Optional: block branch creation on protected patterns --
    creation = local.repo_no_branch_creation[each.key]

    # -- Optional: linear history --
    required_linear_history = local.repo_required_linear_history[each.key]

    # -- PR reviews + merge method enforcement --
    # Always included: enforces merge method (rebase-only default) and PR reviews
    pull_request {
      required_approving_review_count   = local.repo_required_approving_review_count[each.key]
      dismiss_stale_reviews_on_push     = local.repo_required_approving_review_count[each.key] > 0 ? var.dismiss_stale_reviews : false
      require_code_owner_review         = local.repo_require_code_owner_review[each.key]
      require_last_push_approval        = false
      required_review_thread_resolution = false
      allowed_merge_methods             = length(local.repo_allowed_merge_methods[each.key]) > 0 ? local.repo_allowed_merge_methods[each.key] : ["rebase"]
    }

    # -- Required status checks --
    dynamic "required_status_checks" {
      for_each = length(local.repo_ruleset_status_checks[each.key]) > 0 ? [1] : []
      content {
        dynamic "required_check" {
          for_each = local.repo_ruleset_status_checks[each.key]
          content {
            context        = required_check.value.context
            integration_id = required_check.value.integration_id
          }
        }
      }
    }

    # -- Merge queue --
    dynamic "merge_queue" {
      for_each = local.repo_merge_queue[each.key] != null ? [local.repo_merge_queue[each.key]] : []
      content {
        merge_method                      = merge_queue.value.merge_method
        max_entries_to_build              = merge_queue.value.max_entries_to_build
        min_entries_to_merge              = merge_queue.value.min_entries_to_merge
        max_entries_to_merge              = merge_queue.value.max_entries_to_merge
        min_entries_to_merge_wait_minutes = merge_queue.value.min_entries_to_merge_wait_minutes
        grouping_strategy                 = merge_queue.value.grouping_strategy
        check_response_timeout_minutes    = merge_queue.value.check_response_timeout_minutes
      }
    }

    # -- Copilot code review --
    dynamic "copilot_code_review" {
      for_each = local.repo_copilot_code_review[each.key] ? [1] : []
      content {
        review_on_push             = true
        review_draft_pull_requests = true
      }
    }
  }
}
