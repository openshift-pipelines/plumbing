# OpenShift Pipelines — Plumbing

Infrastructure-as-code for the **openshift-pipelines** GitHub organisation.

## Branch Protection

Terraform manages branch-protection rules for every non-archived repository.
The single source of truth is [`config/repos.yaml`](config/repos.yaml).

### How it works

| Component | Path |
|-----------|------|
| Repo / check config | `config/repos.yaml` |
| Terraform module | `terraform/branch-protection/` |
| GitHub Actions workflow | `.github/workflows/branch-protection.yaml` |

1. A push to `main` that touches `config/repos.yaml` or `terraform/branch-protection/**`
   triggers `terraform plan`.
2. A daily cron (`00:00 UTC`) runs `terraform plan` to detect drift.
3. Applying is a manual step until confidence is established (`workflow_dispatch`
   with an `apply` input).

### Local development

```bash
cd terraform/branch-protection
export GITHUB_TOKEN="ghp_…"        # org-admin PAT
terraform init -backend=false      # skip remote state for local dev
terraform plan
```

### Adding a new repo

1. Add the repo name to `config/repos.yaml` under the appropriate category.
2. Open a PR — the workflow will run `terraform plan` and post the diff.
3. Merge — the daily cron (or a manual dispatch with `command=apply`) will apply.
