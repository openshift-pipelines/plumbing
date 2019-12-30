#!/usr/bin/env bash
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

install_local_stuff() {
    echo "------ Installing local templates to run bootstrap"
    for resource in tasks/*.yaml resources/*.yaml;do
        # We may use something fancier than sed (i:e kustomize) in the future
        sed -e "s/%TARGET_NAMESPACE%/${TARGET_NAMESPACE}/g" ${resource} | \
            kubectl apply -f- -n ${TARGET_NAMESPACE}
    done
}

# Utils to delete/create (ie: recreate) easily resource
krecreate () {
	for file in $@;do
		kubectl delete -f $file || true
		kubectl create -f $file
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
	install_local_stuff
}


run() {
	krecreate ./pipeline/ci.yaml ./pipeline/ci-run.yaml
}

main() {
	install
	run
}


main
