* Build special case nop image too... it using tinanon/true atm
* Only generate the bootstrap task (the base task for all others) when a change to the repo is made.
* Move out the large scripts in template to the repository.
* Stream logs to the log server. (extend: https://github.com/chmouel/go-simple-uploader/ )
* Convert base image to CentOS, we are using golang when it's not needed for the base image.
* Move the yum install make from the buildah step to the new CentOS image (so have it buildah in there).
* Investigate if we really need a BASE_IMAGE
* Make sure containers are updated with latest packages (currently disabled for iterations).
* Commonalise the image names for the base golang versions across tasks.
* Push to quay.io release.yaml + nightly images when succeed
* Handle multiple openshift targets
* Rewrite resolv-yamls.sh, it's still as bad as before and didn't have the
  courage to get my head around it. (just made it work for the new CI)
* Use a [S3 bucket](https://git.io/JexBs) when we do private stuff instead of having to do go-simple-uploader.
  (Altought gsu it works well enough for our use case and can give us anonymous/authenticated as we want)
* Create our own SA, don't use existing....
* Remove old crunch like [tasks/components/pipeline/e2e-tests-openshift.sh](tasks/components/pipeline/e2e-tests-openshift.sh)
* Reevaluate the SKIPPED e2e tests for pipelien and see if we can improve.
