set -eux
krec () {
	for a in $@; do
	   kubectl delete -f $a || true
	   kubectl create -f $a
	done
}
cd $(git rev-parse --show-toplevel)/CI

kubectl get -l "tekton.dev/openshift4-install" tr -o name|xargs kubectl delete

REKICKALL=${1-""}

[[ ${REKICKALL} == "-r" ]] && {
    ./local.sh
    krec resources/plumbing-git.yaml resources/tektoncd-pipeline-git.yaml
}

krec tasks/bootstrap/openshift4-install.yaml

tkn task start openshift4-install --showlog \
    --param UPLOADER_HOST=http://$(oc get route -n osinstall uploader -o jsonpath={.spec.host}) \
    --param CLUSTER_NAME=openshift-pipelines-install \
    --param IMAGE_NAME="quay.io/openshift-pipeline/ci:latest" \
    -i plumbing-git=plumbing-git
