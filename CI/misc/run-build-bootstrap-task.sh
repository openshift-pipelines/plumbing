#!/usr/bin/env bash
# Shortcut to run the build bootstrap, just for giggles
set -eu

oc delete taskrun --all;

krec $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline.yaml 

tkn task start build-tektoncd-pipeline-and-push --showlog \
	--param UPLOADER_HOST=http://$(oc get route -n osinstall uploader -o jsonpath={.spec.host}) \
	-i plumbing-git=plumbing-git -i tektoncd-pipeline-git=tektoncd-pipeline-git --serviceaccount builder
