# Openshift Pipelines CI.next

## Components

OpenShift Pipelines (Tekton) is currently made of multiples products :

* openshift/tektoncd-pipeline: **Downstream** TektonCD pipeline
* openshift/tektoncd-cli: **Downstream** TektonCD CLI
* openshift/tektoncd-catalog: **Downstream** TektonCD Catalog
* openshift/pipelines-catalog: **Upstream** OpenShift Pipelines Catalog
* openshift/tektoncd-triggers: **Downstream** TektonCD Triggers
* openshift/tektoncd-pipelines-operator: OpenShift Pipelines Operator

## Current CI overview

We run nightly CI for all repos. The CI on each component (triggers, ci, catalog) will run against the latest nightly CI from `tektoncd-pipelines`'s `release.yaml` unless it failed it will then try to run it against the latest stable release.

`tektoncd-catalog` and `pipelines-catalog` are combined with GIT to get tested together. The CI scripts are different of what used upstream, we have a CI that handles OpenShift security specifics to differentiate between tested that needs serviceAccount (i.e: s2i image builders ) and the other run as user.

# Current release process overview

* [openshift/tektoncd-pipeline](https://github.com/openshift/tektoncd-pipeline):

  Release process document located here :
  https://github.com/openshift/tektoncd-pipeline/blob/master/RELEASE_PROCESS.md

  Steps are :

  1) Create release branch and push to `openshift/tektoncd-pipeline`
  2) Create a PR on `openshift/release` to add CI and image mirroring to quay
     for the release branch.
  3) Create a PR against the release branch in `openshift/tektoncd-pipeline`
  with a newly generated `release.yaml`

* [openshift/tektoncd-catalog](https://github.com/openshift/tektoncd-catalog):
  Same steps as `openshift/tektoncd-pipeline` and located in the same [release process document](https://github.com/openshift/tektoncd-pipeline/blob/master/RELEASE_PROCESS.md).

* [openshift/pipelines-catalog](https://github.com/openshift/pipelines-catalog):
  Manual tagging/branch, no documention.

* [openshift/tektoncd-cli](https://github.com/openshift/tektoncd-cli):
  No downstream release, we are using upstream CLI.

* [openshift/tektoncd-triggers](https://github.com/openshift/tektoncd-triggers):
  Manual tagging/branch, no documention.

* [openshift/tektoncd-pipeline-operator](https://github.com/openshift/tektoncd-pipeline-operator)
  TBF: Documentation is [here](https://github.com/openshift/tektoncd-pipeline-operator/blob/master/docs/release.md)

## OpenShift Pipelines CI.next

### Requirements

  * Monorepo CI with a top to bottom approach, if pipelines fails all the other fails.
  * Tekton based.
  * Run from the [devint](https://github.com/openshift-knative/cluster-devint) cluster.
  * Run quietly, err verbosely. (less noise).
  * Store artifacts. (ie `release.yaml`).
  * Support credential install.

### Optional / crazy long shot

   * Overview Dashboard of all runs.
   * Can be run from developer laptop.
   * CI runs Metrics with performances and slowness detection.
   * Error logs detection.

### Implementation

   * task1:
       - using a buildah image

       - checkout `openshift-pipelines/plumbing` as tekton git resource

       - generate a container image from a Dockerfile with :
         - Binaries: `oc`, `openshift4-install` `git`, `go`, `make`
         - Probably other utilities and other tools for building application.
         - Add `plumbing` repository somewhere into the image
         - Not necessary but that would make things easier further down.

       -  push it to the internal openshift registry.

   * task2:
       - run after task1

       - using generated image from previous step.

       - checkout `openshift-pipelines/plumbing` repo as tekton git resources.

       - start and wait for an openshift4 temporary cluster install using an
         openshift ci registry token.

         (**TBD**: which token? a user one or req a stable one?)

        - store generated kubeconfig and password in an artifacts/object storage/content repository

          (**TBD**: we need to figure out a way to store securely store a
          kubeconfig and other password, in a content repository or object
          storage, I have already make this simple python app for that same use
          case which can be extended/moved but that need to be designed
          carefully with security in mind
          https://github.com/chmouel/openshift4-nightly-reinstall/tree/master/os4-simple-uploader)

    * task3 :
       - run after task2

       - using generated image from task1

       - checkout nightly or specific revision `tektoncd/pipeline` using tekton git resources.

       - compile all pipeline binaries from `tektoncd/pipeline` to a location

        (ie: with a Makefile located inside openshift-pipelines/plumbing doing a `make install` Makefile)

       - get location from the artifacts repository and grab the `kubeconfig`

       - using a simple yaml from `openshift-pipelines/plumbing` with
         definitions on how to make the images (ie:
         `tektoncd-pipeline-imagedigestexporter` `tektoncd-pipeline-git-init` etc..)

       - push images using the temporary cluster kubeconfig to the internal registry from the temporary cluster.

       - generate a `release-nightly-internal.yaml` using the image references
         from the temporary cluster and store it into the content-repository.

       - using temporary cluster kubeconfig install the `release-nightly-internal.yaml` into the temporary cluster.

       - tekton should get installed using the internal image registry

       - using temporarary cluster kubeconfig start the `e2e-tests.sh` script.

       - report back that we are cool.

   * task4:
       - Run after task3

       - using generated image from task1

       - checkout nightly or specific revision `tektoncd/cli` using tekton git resources.

       - get location from the artifacts repository and grab the `kubeconfig`

       - Run cli e2e-scripts

       - Note: we may need some specific configuration for how to run the tests
         on openshift compared to upstream CI scripts which could be located in
         the `tektoncd-plumbing` image (since remember that repo is baked into
         the image).

   * task5: same process as for other repos can be run in parallel of task4 only
     needs to be after task3.
