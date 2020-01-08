#!/bin/bash
set -eux
krec () {
	for a in $@; do
	   kubectl delete -f $a || true
	   kubectl create -f $a
	done
}
cd $(git rev-parse --show-toplevel)/CI

kubectl get -l "tekton.dev/task=pipeline-test" tr -o name|xargs kubectl delete

REKICKALL=${1-""}

[[ ${REKICKALL} == "-r" ]] && {
    ./local.sh
    krec resources/plumbing-git.yaml resources/tektoncd-pipeline-git.yaml tasks/components/pipeline.yaml
}

tkn task start pipeline-test --showlog \
    --param UPLOADER_HOST=$(grep host ~/.uploader.cfg|sed 's/host=//') \
    --param CLUSTER_NAME=openshift-pipelines-install \
    --param IMAGE_NAME="quay.io/openshift-pipeline/ci:bootstrap" \
    -i plumbing-git=plumbing-git -i tektoncd-pipeline-git=tektoncd-pipeline-git
