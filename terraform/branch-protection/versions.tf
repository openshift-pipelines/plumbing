terraform {
  required_version = ">= 1.5"

  # State stored in the GitHub Actions cache via terraform-backend-git,
  # or locally with -backend=false for development.
  # In CI the workflow uses a dedicated state branch.
  backend "local" {}

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "openshift-pipelines"
}
