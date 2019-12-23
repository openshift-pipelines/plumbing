#!/bin/bash
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

install_local_resources() {
    echo "------ Installing resources to run bootstrap"
    for resource in resources/*.yaml;do
        # We may use something fancier than sed (i:e kustomize) in the future
        sed -e "s/%TARGET_NAMESPACE%/${TARGET_NAMESPACE}/g" ${resource} | \
            kubectl apply -f- -n ${TARGET_NAMESPACE}
    done
}

recreate () {
	for file in $@
	do
		for action in delete create
		do
			kubectl $action -f $file
		done
	done
}

# We use the builder image for our building task until buildah can build without
# privileged
oc adm policy add-scc-to-user privileged -z builder 2>/dev/null || true

kubectl create ns ${TARGET_NAMESPACE} 2>/dev/null || true

install_catalog_tasks
install_local_resources

recreate ./pipeline/ci.yaml ./pipeline/ci-run.yaml
