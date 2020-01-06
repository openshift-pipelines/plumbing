#!/usr/bin/env bash
# Main install script. This probably would only install script in the future,
# (or when doing a push to the repo this would get run to reinstall a la gitops)

set -eu

# Target namespace on the cluster
TARGET_NAMESPACE=ci-openshift-pipelines

# Catalog tasks to install
CATALOG_TASKS="buildah/buildah"
# Catalog branch where to install our remote tasks
CATALOG_BRANCH=master


install_catalog_tasks() {
    echo "------ Installing catalog tasks"
    for task in ${CATALOG_TASKS};do
        curl -Ls -f https://raw.githubusercontent.com/tektoncd/catalog/${CATALOG_BRANCH}/${task}.yaml | kubectl apply -f- -n ${TARGET_NAMESPACE}
    done
}

install() {
	# We do this so we can have some custom configuration in there, i.e: installing secret
	[[ -e ./local.sh ]] && source "./local.sh"

	oc project ${TARGET_NAMESPACE} 2>/dev/null >/dev/null ||
		oc new-project ${TARGET_NAMESPACE}

	# We use the builder image for our building task until buildah can build without
	# privileged
	oc get scc privileged -o yaml|grep -q -- "- system:serviceaccount:${TARGET_NAMESPACE}:builder" ||
		oc adm policy add-scc-to-user privileged -z builder

	kubectl create ns ${TARGET_NAMESPACE} 2>/dev/null || true

	install_catalog_tasks

	echo "------ Installing local templates to run bootstrap"
    kubectl apply -f resources -f tasks/bootstrap/ -f tasks/components/

}


run() {
	kubectl delete -f ./pipeline/ci.yaml -f ./pipeline/ci-run.yaml 2>/dev/null || true
	kubectl create -f ./pipeline/ci.yaml -f ./pipeline/ci-run.yaml
}

main() {
	install
	run
}


main
