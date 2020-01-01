#!/usr/bin/env bash
set -eu

TMP=$(mktemp /tmp/.mm.XXXXXX)
clean() { rm -f ${TMP}; }
trap clean EXIT

# Take all yamls in $dir and generate a all in one yaml file with resolved registry image/tag
function resolve_resources() {
    local dir=$1
    local resolved_file_name=$2
    local ignores=$3
    local registry_prefix=$4
    local image_tag=
    local cmd

    # Build all binaries as regexps
    image_regexp=""
    for cmd in ${dir}/../cmd/*;do
        image_regexp="$(basename $cmd)|${image_regexp}"
    done
    image_regexp="(${image_regexp%|})"

    >$resolved_file_name
    for yaml in $(find $dir -name "*.yaml" | grep -vE $ignores | sort); do
        echo "---" >>$resolved_file_name
        if [[ -n ${image_tag} ]];then
            # This is a release format the output would look like this :
            # quay.io/openshift-pipeline/tektoncd-pipeline-bash:$image_tag
            #
            # tianon/true => openshift/ci-operator/tekton-images/nop/Dockerfile
            # busybox => registry.access.redhat.com/ubi8/ubi-minimal:latest \
            # TODO: gcs-util is still going external and not ubi based
            sed -e "s%tianon/true%${registry_prefix}-nop:${image_tag}%" \
                -e "s%busybox%registry.access.redhat.com/ubi8/ubi-minimal:latest%" \
                -e "s%\(.* image: \)\(github.com\)\(.*\/\)\(.*\)%\1 ${registry_prefix}-\4:${image_tag}%" \
                -r -e "s,github.com/tektoncd/pipeline/cmd/${image_regexp},${registry_prefix}-\1:${image_tag},g" \
                $yaml > ${TMP}
        else
            # This is CI which get built directly to the user registry namespace i.e: $OPENSHIFT_BUILD_NAMESPACE
            # The output would look like this :
            # internal-registry:5000/usernamespace:tektoncd-pipeline-bash
            sed -e "s%tinaon/true%${registry_prefix}/nop%" \
                -e "s%busybox%registry.access.redhat.com/ubi8/ubi-minimal:latest%" \
                -e 's%\(.* image: \)\(github.com\)\(.*\/\)\(test\/\)\(.*\)%\1\2 \3\4test-\5%' \
                -e "s%\(.* image: \)\(github.com\)\(.*\/\)\(.*\)%\1 ""$registry_prefix"'/\4%'  \
                -re "s,github.com/tektoncd/pipeline/cmd/${image_regexp},${registry_prefix}/\1,g" \
                $yaml > ${TMP}
        fi

        # Adding the labels: openshift.io/cluster-monitoring on Namespace to add the cluster-monitoring
        # See: https://docs.openshift.com/container-platform/4.1/logging/efk-logging-deploying.html
        grep -q "kind: Namespace" ${TMP} && sed -i '/^metadata:/a \ \ labels:\n\ \ \ \ openshift.io/cluster-monitoring:\ \"true\"' ${TMP}
        cat ${TMP} >> $resolved_file_name
        echo >>$resolved_file_name
    done

    # handle additional images which are not build from ./cmd (images not in $CORE_IMAGES)
    if [[ -n ${image_tag} ]];then
        sed -i -r -e "s,github.com/tektoncd/pipeline/vendor/github.com/GoogleCloudPlatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher,${registry_prefix}-gcs-fetcher:${image_tag},g" $resolved_file_name
    else
        sed -i -r -e "s,github.com/tektoncd/pipeline/vendor/github.com/GoogleCloudPlatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher,${registry_prefix}/gcs-fetcher,g" $resolved_file_name
    fi
}

function generate_pipeline_resources() {
    local pipeline_dir=$1
    local output_file=$2
    local image_prefix=$3
    local image_tag=

    resolve_resources ${pipeline_dir}/config $output_file noignore $image_prefix $image_tag

    # Appends addon configs such as prometheus monitoring config
    for yaml in $(find CI/tasks/bootstrap/build-tektoncd-pipeline/addons -name "*.yaml" | sort); do
        echo "---" >> $output_file
        cat ${yaml} >> $output_file
    done
}

generate_pipeline_resources $@
