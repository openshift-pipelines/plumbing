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

# Service Account to run the CI with
SERVICE_ACCOUNT=builder

install_catalog_tasks() {
    echo -e "------ \e[96mInstalling catalog tasks\e[0m"
    for task in ${CATALOG_TASKS};do
        curl -Ls -f https://raw.githubusercontent.com/tektoncd/catalog/${CATALOG_BRANCH}/${task}.yaml | \
            kubectl apply -f- -n ${TARGET_NAMESPACE}
    done
}

install() {
	oc project ${TARGET_NAMESPACE} 2>/dev/null >/dev/null || {
        echo -e "------ \e[96mCreating Project: ${TARGET_NAMESPACE}\e[0m"
		oc new-project ${TARGET_NAMESPACE} >/dev/null
    }

	# We do this so we can have some custom configuration in there, i.e: installing secret
	[[ -e ./local.sh ]] && source "./local.sh"

	# We use the builder image for our building task until buildah can build without
	# privileged
    echo -e "------ \e[96mSetting Service Account ${SERVICE_ACCOUNT} as privileged\e[0m"
	oc get scc privileged -o yaml|grep -q -- "- system:serviceaccount:${TARGET_NAMESPACE}:${SERVICE_ACCOUNT}" ||
		oc adm policy add-scc-to-user privileged -z ${SERVICE_ACCOUNT}

	install_catalog_tasks

	echo -e "------ \e[96mInstalling local templates to run bootstrap\e[0m"
    kubectl apply -f resources -f tasks/bootstrap/ -f tasks/components/
}


run() {
    echo -e "------ \e[96mCreating pipeline and run\e[0m"
	kubectl delete -f ./pipeline/ci.yaml -f ./pipeline/ci-run.yaml 2>/dev/null || true
	kubectl create -f ./pipeline/ci.yaml -f ./pipeline/ci-run.yaml
    echo -e "------ \e[96mFollow progress with: \e[0m"
    echo "tkn pipeline logs openshift-pipeline-ci -f"

}

main() {
	install
	run
}


main
