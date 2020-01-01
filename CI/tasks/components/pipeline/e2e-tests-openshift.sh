#!/usr/bin/env bash
set -eux
source $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline/resolve-yamls.sh

readonly OPENSHIFT_REGISTRY=${1}
readonly REPO_OUTPUT=${2}
readonly PIPELINE_REPOSITORY=${3}

[[ -z ${OPENSHIFT_REGISTRY} || -z ${REPO_OUTPUT}  || -z ${PIPELINE_REPOSITORY} ]] && {
    echo "args in order: OPENSHIFT_REGISTRY REPO_OUTPUT PIPELINE_REPOSITORY"
    exit 1
}

[[ -d ${REPO_OUTPUT} ]] || mkdir -p ${REPO_OUTPUT}

readonly TIMESTAMP="$(date "+%Y%m%d-%Hh%m")"
readonly TEST_NAMESPACE=tekton-pipeline-tests-${TIMESTAMP}
readonly TEST_YAML_NAMESPACE=tekton-pipeline-tests-yaml-${TIMESTAMP}

readonly IGNORES="pipelinerun.yaml|pull-private-image.yaml|build-push-kaniko.yaml|gcs|git-volume.yaml"

# Yaml test skipped due of not being able to run on openshift CI, usually becaus
# of rights.
# test-git-volume: `"gitRepo": gitRepo volumes are not allowed to be used]'
# dind-sidecar-taskrun-1: securityContext.privileged: Invalid value: true: Privileged containers are not allowed]
# gcs: google container storage
declare -ar SKIP_YAML_TEST=(test-git-volume dind-sidecar-taskrun-1 build-gcs-targz build-gcs-zip gcs-resource)

function create_test_namespaces() {
  for ns in ${TEST_YAML_NAMESPACE} ${TEST_NAMESPACE};do
     oc get project ${ns} >/dev/null 2>/dev/null || oc new-project ${ns}
  done
}

function run_go_e2e_tests() {
  echo ">>>>>>>>>>>>>>>>>>>>>"
  echo "Running Go e2e tests"
  echo ">>>>>>>>>>>>>>>>>>>>>"
  go test -v -failfast -count=1 -tags=e2e \
     -ldflags '-X github.com/tektoncd/pipeline/test.missingKoFatal=false -X github.com/tektoncd/pipeline/test.skipRootUserTests=true' \
     ./test -timeout=20m || return 1
}

function run_yaml_e2e_tests() {
  echo ">>>>>>>>>>>>>>>>>>>>>>>"
  echo "Running YAML e2e tests"
  echo ">>>>>>>>>>>>>>>>>>>>>>>"
  oc project $TEST_YAML_NAMESPACE
  resolve_resources ${PIPELINE_REPOSITORY}/examples/ ${REPO_OUTPUT}/tests-resolved.yaml $IGNORES ${OPENSHIFT_REGISTRY}
  oc apply -f ${REPO_OUTPUT}/tests-resolved.yaml

  # Wait for tests to finish.
  echo ">> Waiting for tests to finish"
  for test in taskrun pipelinerun; do
    if validate_run ${test}; then
      echo "ERROR: tests timed out"
    fi
  done

  # Check that tests passed.
  echo ">> Checking test results"
  for test in taskrun pipelinerun; do
    if check_results ${test}; then
      echo ">> All YAML tests passed"
      return 0
    fi
  done

  return 1
}

function validate_run() {
  local tests_finished=0
  for i in {1..120}; do
    local finished="$(kubectl get $1.tekton.dev --output=jsonpath='{.items[*].status.conditions[*].status}')"
    if [[ ! "$finished" == *"Unknown"* ]]; then
      tests_finished=1
      break
    fi
    sleep 10
  done

  return ${tests_finished}
}

function check_results() {
  local failed=0
  results="$(kubectl get $1.tekton.dev --output=jsonpath='{range .items[*]}{.metadata.name}={.status.conditions[*].type}{.status.conditions[*].status}{" "}{end}')"
  for result in ${results}; do
    reltestname=${result/=*Succeeded*/}
    skipit=
    for skip in ${SKIP_YAML_TEST[@]};do
        [[ ${reltestname} == ${skip} ]] && skipit=True
    done
    [[ -n ${skipit} ]] && {
        echo ">>> INFO: skipping yaml test ${reltestname}"
        continue
    }
    if [[ "${result,,}" != *"=succeededtrue" ]]; then
      echo ">>> ERROR: test ${result} but should be succeededtrue"
      echo ">>> $1.tekton.dev/${reltestname} YAML DUMP"
      kubectl get $1.tekton.dev ${reltestname} -o yaml
      echo ">>> $1.tekton.dev/${reltestname} LOG OUTPUT"
      kubectl logs --all-containers \
              $(kubectl get taskrun.tekton.dev ${reltestname} -o yaml|sed -n '/podName: / { s/.*podName: //;p;}')
      failed=1
    fi
  done

  return ${failed}
}

create_test_namespaces

failed=0

cd ${PIPELINE_REPOSITORY}

run_go_e2e_tests || failed=1
run_yaml_e2e_tests || failed=1

((failed)) && {
    echo ">>> FAILED"
    exit 1
}

echo ">>> SUCCESS"
