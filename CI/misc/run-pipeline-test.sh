#!/usr/bin/env bash
set -eu
krec () {
	for a in $@; do
	   kubectl delete -f $a || true
	   kubectl create -f $a
	done
}
cd $(git rev-parse --show-toplevel)/CI
source config.sh

kubectl get -l "tekton.dev/task=pipeline-test" tr -o name|xargs kubectl delete

REKICKALL=${1-""}

[[ ${REKICKALL} == "-r" ]] && {
    krec resources/plumbing-git.yaml resources/tektoncd-pipeline-git.yaml tasks/components/pipeline.yaml
}

tkn task start pipeline-test --showlog \
    --param UPLOADER_HOST=${UPLOADER_HOST} \
    --param CLUSTER_NAME=openshift-pipelines-install \
    --param IMAGE_NAME="quay.io/openshift-pipeline/ci:bootstrap" \
    -i plumbing-git=plumbing-git -i tektoncd-pipeline-git=tektoncd-pipeline-git
