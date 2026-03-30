# -----------------------------------------------------------------
# Import existing branch protection rules into Terraform state.
#
# These repos already had branch protection before Terraform was
# introduced. The import blocks allow Terraform to adopt them
# without requiring manual `terraform import` commands.
#
# Format: "{repo_node_id}:{branch_pattern}"
# -----------------------------------------------------------------

# -- Default branch protection (already existed) --

import {
  to = github_branch_protection.default["catalog-cd"]
  id = "R_kgDOLJihyA:main"
}

import {
  to = github_branch_protection.default["console-plugin"]
  id = "R_kgDOKZDJaQ:main"
}

import {
  to = github_branch_protection.default["hack"]
  id = "R_kgDOK22vEg:main"
}

import {
  to = github_branch_protection.default["performance"]
  id = "R_kgDOKg2Clg:main"
}

import {
  to = github_branch_protection.default["pipeline-service"]
  id = "R_kgDOGdSpEg:main"
}

import {
  to = github_branch_protection.default["release-tektoncd-task"]
  id = "R_kgDOJQ2esQ:main"
}

import {
  to = github_branch_protection.default["setup-tektoncd-cli"]
  id = "R_kgDOJJXtSg:main"
}

import {
  to = github_branch_protection.default["task-containers"]
  id = "R_kgDOJHVbFw:main"
}

import {
  to = github_branch_protection.default["task-git"]
  id = "R_kgDOJHVa9w:main"
}

import {
  to = github_branch_protection.default["task-openshift"]
  id = "R_kgDOKp36Wg:main"
}

import {
  to = github_branch_protection.default["tektoncd-pruner"]
  id = "R_kgDOMc-l1g:main"
}

import {
  to = github_branch_protection.default["tekton-task-group"]
  id = "R_kgDOHDMFgw:main"
}

# -- Release-* branch protection (already existed) --

import {
  to = github_branch_protection.releases["docs"]
  id = "R_kgDOHnF4ew:release-*"
}

import {
  to = github_branch_protection.releases["ecosystem-images"]
  id = "R_kgDOLelIDA:release-*"
}

import {
  to = github_branch_protection.releases["operator-downgrade"]
  id = "R_kgDORSNNDQ:release-*"
}

import {
  to = github_branch_protection.releases["release-tests"]
  id = "MDEwOlJlcG9zaXRvcnkyMjcwMzA4NDQ=:release-*"
}

import {
  to = github_branch_protection.releases["release-ui-tests"]
  id = "R_kgDOQeqBUA:release-*"
}

import {
  to = github_branch_protection.releases["skills"]
  id = "R_kgDOQ4-3uA:release-*"
}
