#!/usr/bin/env bash
# Shortcut to run the build bootstrap, just for giggles
set -eu

kubectl delete taskrun --all;

for i in delete create;do
    kubectl ${i} -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline.yaml
done

tkn task start build-tektoncd-pipeline-and-push --showlog \
	--param UPLOADER_HOST=http://$(oc get route -n osinstall uploader -o jsonpath={.spec.host}) \
	-i plumbing-git=plumbing-git -i tektoncd-pipeline-git=tektoncd-pipeline-git --serviceaccount builder
