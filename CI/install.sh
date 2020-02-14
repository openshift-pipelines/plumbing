#!/usr/bin/env bash
# Main install script. This probably would only install script in the future,
# (or when doing a push to the repo this would get run to reinstall a la gitops)

set -eu

# Settings you are probably not going to change
#
# Catalog tasks to install
CATALOG_TASKS="buildah/buildah"

# Catalog branch where to install our remote tasks
CATALOG_BRANCH=master

[[ -e config.sh ]] || {
    echo "You need to configure your config.sh see config.sh.samples for how to do this"
    exit 1
}

norun=

while getopts "n" o; do
    case "${o}" in
        n)
            norun=yes;
            ;;
        *)
            echo "Invalid option"; exit 1;
            ;;
    esac
done
shift $((OPTIND-1))

source config.sh

K="kubectl -n ${TARGET_NAMESPACE}"


install_catalog_tasks() {
    echo -e "------ \e[96mInstalling catalog tasks\e[0m"
    for task in ${CATALOG_TASKS};do
        curl -Ls -f https://raw.githubusercontent.com/tektoncd/catalog/${CATALOG_BRANCH}/${task}.yaml | \
            ${K} apply -f-
    done
}

install() {
	# We do this here so we can have some custom configuration in there, i.e: installing secret
	[[ -e ./local.sh ]] && source "./local.sh"

	install_catalog_tasks

	echo -e "------ \e[96mInstalling local templates\e[0m"
    ${K} apply -f <(config_params resources/) -f <(config_params tasks/bootstrap/) \
			-f <config_params tasks/bootstrap/cronjobs/) -f <(config_params tasks/components/) || {
		tmpf=$TMPDIR/apply-failed-$$.yaml
        cat <(config_params resources/) <(config_params tasks/bootstrap/) <(config_params tasks/components/) > ${tmpf}
		echo "Applying resources failed; template avaialble here: ${tmpf}"
        exit 1
    }

    # Soon enough we will convert all task to  use this script
    ./misc/make-task.py tasks/bootstrap/templates | kubectl apply -f-

    echo -e "------ \e[96mCreating pipeline and triggers notifications\e[0m"
	kubectl delete -f <(config_params triggers/) -f <(config_params ./pipeline/ci.yaml) 2>/dev/null || true
	kubectl create -f <(config_params triggers/) -f <(config_params ./pipeline/ci.yaml)
    kubectl delete -f ./triggers/routes.yaml 2>/dev/null || true
    kubectl create --validate=false -f ./triggers/routes.yaml
}

config() {
	oc project ${TARGET_NAMESPACE} 2>/dev/null >/dev/null || {
        echo -e "------ \e[96mCreating Project: ${TARGET_NAMESPACE}\e[0m"
		oc new-project ${TARGET_NAMESPACE} >/dev/null
    }

    echo -e "------ \e[96mSettings openshift-install secret\e[0m"
    ${K} delete secret openshift-install 2>/dev/null >/dev/null || true
    # TODO: Convert console-url as params instead?
    ${K} create secret generic openshift-install \
		  --from-literal="console-url=${CONSOLE_URL}" \
		  --from-literal="github-token=${GITHUB_TOKEN}" \
		  --from-literal="slack-webhook-url=${SLACK_WEBHOOK_URL}" \
          --from-literal="aws-access-key-id=${AWS_SECRET_KEY}" \
          --from-literal="aws-secret-access-key=${AWS_ACCESS_KEY}" \
          --from-literal="uploader-username=${UPLOADER_USERNAME}" \
          --from-literal="uploader-password=${UPLOADER_PASSWORD}" \
          --from-file=public-ssh-key="${PUBLIC_SSH_KEY}" \
          --from-file=registry-token="${OPENSHIFT_INSTALL_REGISTRY_TOKEN}" \
          --from-file=upload-pubring.gpg="${DEVELOPPER_PUBRING}"

    echo -e "------ \e[96mConfiguring SA ${SERVICE_ACCOUNT} with your quay registry config\e[0m"
    ${K} delete secret quay-reg-cred 2>/dev/null >/dev/null || true
    ${K} create secret generic quay-reg-cred \
            --from-file=.dockerconfigjson="${QUAY_REGISTRY_CONFIG}" \
            --type=kubernetes.io/dockerconfigjson

    ${K} get sa ${SERVICE_ACCOUNT} -o yaml | grep -q -- '- name: quay-reg-cred' || {
        ${K} get sa ${SERVICE_ACCOUNT} -o json | \
            python -c "import json, sys;r = json.loads(sys.stdin.read());r['secrets'].append({'name': 'quay-reg-cred'});print(json.dumps(r))"|${K} apply -f-
    }

    collectlogs_deployed=$(${K} get deployment collectlogs -oname 2>/dev/null || true)
    if [[ -n ${collectlogs_deployed} ]];then
        TRIGGERS_URL="https://$(${K} get route webhook -o jsonpath='{.spec.host}')"
        echo -e "------ \e[96mSetting collectlogs to send pr events to webhook service\e[0m"
        ${K} set env deployment/collectlogs -c operator TRIGGERS_URL="${TRIGGERS_URL}"
    fi
}

# This takes a a dir or a file and apply environment variable (configs) to it.
# If you specify a dir it would get all the yaml files in there or fail
# miserably if you called it .yml!
# TODO: move to kustomize
config_params() {
    if [[ -d $1 ]];then
        files=(${1}/*.yaml)
    else
        files=($@)
    fi

    sed -e "s\\%SERVICE_ACCOUNT%\\${SERVICE_ACCOUNT}\\" \
        -e "s\\%UPLOADER_HOST%\\${UPLOADER_HOST}\\" \
        -e "s\\%GITHUB_USER%\\${GITHUB_USER}\\" \
        ${files[@]}
}

main() {
    config
	install
}

main
