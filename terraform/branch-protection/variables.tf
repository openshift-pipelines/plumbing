variable "enforce_admins" {
  description = "Enforce branch protection for admins"
  type        = bool
  default     = false
}

variable "require_signed_commits" {
  description = "Require signed commits"
  type        = bool
  default     = false
}

variable "required_linear_history" {
  description = "Require linear history (no merge commits)"
  type        = bool
  default     = false
}

variable "allow_force_pushes" {
  description = "Allow force pushes"
  type        = bool
  default     = false
}

variable "allow_deletions" {
  description = "Allow branch deletions"
  type        = bool
  default     = false
}

variable "required_approving_review_count" {
  description = "Number of required approving reviews"
  type        = number
  default     = 1
}

variable "dismiss_stale_reviews" {
  description = "Dismiss stale pull request approvals when new commits are pushed"
  type        = bool
  default     = true
}

variable "require_code_owner_reviews" {
  description = "Require review from code owners"
  type        = bool
  default     = false
}

variable "require_conversation_resolution" {
  description = "Require all conversations to be resolved before merging"
  type        = bool
  default     = false
}

variable "release_required_approving_review_count" {
  description = "Number of required approving reviews for release branches"
  type        = number
  default     = 1
}
