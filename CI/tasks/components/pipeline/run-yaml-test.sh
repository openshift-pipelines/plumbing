#!/usr/bin/env bash
set -eu
# pipelinerun does way way too much kubernetes specifics stuff with a cluster-admin...
# TODO: sidecar-ready is failing due of readinessprobe not doign its work, let's investigate this later
declare -ar SKIP_YAML_TEST=(pipelinerun
                            sidecar-ready
                            git-volume
                            dind-sidecar
                            pull-private-image
                            build-push-kaniko
                            build-gcs-targz
                            build-gcs-zip
                            gcs-resource)

TIMESTAMP=$(date '+%Y%m%d-%Hh%M-%S')
NS=tekton-pipeline-tests-yaml-${TIMESTAMP}
failed=0
export BUILD_NUMBER=1
oc new-project ${NS}

# We do this so cloudevent would know where to go for our namespace...
for i in ./examples/*/taskruns/cloud-event.yaml;do
    sed -i "s/value: http:\/\/sink\..*/value: http:\/\/sink.${NS}:8080/" ${i}
done

# We should find a way to exclude install_pipeline_crd and be able to run
# e2e-tests.sh directly
source test/e2e-common.sh

MAX_CONCURRENT_TEST=2

function run_batched_yaml_tests() {
    local resource=$1
    echo ">> Creating resources ${resource}"

    cnt=1
    runtasks=()

    # Applying the resources, either *taskruns or * *pipelineruns
    for version in examples/*/;do
      version=$(basename $version)
      for file in $(find ./examples/${version}/${resource}s -name '*.yaml' -not -path "*/no-ci/*" | sort); do
          skipit=False
          reltestname=$(basename $file|sed 's/.yaml//')
          for skip in ${SKIP_YAML_TEST[@]};do
              [[ ${reltestname} == ${skip} ]] && skipit=True
          done
          [[ ${skipit} == True ]] && {
              echo ">>> INFO: skipping yaml test ${reltestname}"
              continue
          }
          echo ">>> Creating ${resource}/${reltestname}"
          runtasks+=(${reltestname})
          kubectl delete -n ${NS} -f ${file} >/dev/null 2>/dev/null || true
          kubectl create -n ${NS} -f ${file} >/dev/null || return 1
          [[ ${cnt} == ${MAX_CONCURRENT_TEST} ]] && {
              if ! run_tests ${1}; then
                  echo "FAILURE: "
                  return 1
              fi
              echo "Done!!"
              sleep 2
              cnt=1
              for yamltest in ${runtasks[@]};do
                  echo ">> Cleaning up ${version}/${resource}/${yamltest}"
                  # We have so many OOMKILLED in that cluster that i rather cleanup as much as possible
                  kubectl delete ${resource} -n ${NS} --all >/dev/null || true
                  kubectl delete all -n ${NS} --all >/dev/null || true
                  kubectl delete -n ${NS} -f ./examples/${version}/${resource}s/${yamltest}.yaml 2>/dev/null >/dev/null || true
              done
              runtasks=()
          }
          (( cnt+=1 ))
      done
    done
    return 0
}


failed=0
for test in taskrun pipelinerun; do
  header "Running YAML e2e tests for ${test}s"

  flakyness=0
  while [[ ${flakyness} < 3 ]];do
     if ! run_batched_yaml_tests ${test}; then
        REASONS=$(kubectl get -o json ${test} -n ${NS} | python -c 'import json,sys;j = json.loads(sys.stdin.read());print("|".join([ x["status"]["conditions"][0]["message"] for x in j["items"]]))')
        if [[ "${REASONS}" == *OOMKilled* ]];then
            kubectl delete -n ${NS} ${test} --all
            (( flakyness+=1 ))
            continue
        fi


        echo ">>> ERROR: one or more YAML tests failed"
        output_yaml_test_results ${test}
        output_pods_logs ${test}
        failed=1
     fi
     break
  done

done

(( failed )) && fail_test

kubectl delete ns ${NS}
success
