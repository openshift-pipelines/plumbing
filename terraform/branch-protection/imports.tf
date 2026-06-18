# -----------------------------------------------------------------
# Import existing manually-created rulesets named "default"
# These will be adopted by Terraform and managed going forward.
# Remove this file after the first successful apply.
# -----------------------------------------------------------------

import {
  to = github_repository_ruleset.default["tektoncd-pruner"]
  id = "tektoncd-pruner:3276049"
}

import {
  to = github_repository_ruleset.default["operator"]
  id = "operator:2090492"
}

import {
  to = github_repository_ruleset.default["manual-approval-gate"]
  id = "manual-approval-gate:3276063"
}

import {
  to = github_repository_ruleset.default["tektoncd-pipeline"]
  id = "tektoncd-pipeline:2183775"
}

import {
  to = github_repository_ruleset.default["tektoncd-chains"]
  id = "tektoncd-chains:2204695"
}

import {
  to = github_repository_ruleset.default["tektoncd-cli"]
  id = "tektoncd-cli:2204720"
}

import {
  to = github_repository_ruleset.default["tektoncd-triggers"]
  id = "tektoncd-triggers:2204745"
}

import {
  to = github_repository_ruleset.default["tektoncd-hub"]
  id = "tektoncd-hub:2204727"
}

import {
  to = github_repository_ruleset.default["pac-downstream"]
  id = "pac-downstream:3276077"
}
