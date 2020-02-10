#!/usr/bin/env bash
# Shortcut to run the build bootstrap, just for giggles
set -eu

source $(git rev-parse --show-toplevel)/CI/config.sh

git push -q

kubectl get -l "tekton.dev/task=triggers-build-test" tr -o name|xargs kubectl delete

kubectl delete -f $(git rev-parse --show-toplevel)/CI/tasks/components/triggers.yaml 2>/dev/null || true
kubectl create -f $(git rev-parse --show-toplevel)/CI/tasks/components/triggers.yaml

tkn task start triggers-build-test --showlog \
    --param UPLOADER_HOST=${UPLOADER_HOST} \
    --param IMAGE_NAME="quay.io/openshift-pipeline/ci:bootstrap" \
    --param CLUSTER_NAME=openshift-pipelines-install \
	-i plumbing-git=plumbing-git \
    -i tektoncd-triggers-git=tektoncd-triggers-git \
    --serviceaccount ${SERVICE_ACCOUNT}
