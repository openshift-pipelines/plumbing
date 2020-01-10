#!/usr/bin/env bash
# Shortcut to run the build bootstrap, just for giggles
set -eu

git push

kubectl get -l "tekton.dev/task=build-tektoncd-pipeline-and-push" tr -o name|xargs kubectl delete

kubectl delete -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline.yaml 2>/dev/null || true
kubectl create -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline.yaml

tkn task start build-tektoncd-pipeline-and-push --showlog \
    --param UPLOADER_HOST=$(grep host ~/.uploader.cfg|sed 's/host=//') \
	-i plumbing-git=plumbing-git \
    -i tektoncd-pipeline-git=tektoncd-pipeline-git \
    --serviceaccount builder
