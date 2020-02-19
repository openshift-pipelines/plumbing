#!/usr/bin/env bash
# Run cl-build task
set -eu

source $(git rev-parse --show-toplevel)/CI/config.sh

git push -q

TN=cli-build

kubectl get -l "tekton.dev/task=${TN}" tr -o name|xargs kubectl delete

kubectl delete -f $(git rev-parse --show-toplevel)/CI/tasks/components/cli.yaml 2>/dev/null || true
kubectl create -f $(git rev-parse --show-toplevel)/CI/tasks/components/cli.yaml

tkn task start ${TN} --showlog \
	-i tektoncd-cli-git=tektoncd-cli-git \
    --serviceaccount ${SERVICE_ACCOUNT}
