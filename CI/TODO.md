* Only generate the bootstrap task (the base task for all others) when a change to the repo is made.
* Move out the large scripts in template to the repository.
* Stream logs to the log server. (extend: https://github.com/chmouel/go-simple-uploader/ )
* Convert base image to CentOS, we are using golang when it's not needed for the base image.
* Move the yum install make from the buildah step to the new CentOS image (so have it buildah in there).
* Make sure containers are updated with latest packages (currently disabled for iterations).
* Commonalise the image names for the base golang versions across tasks.
* Build special case nop image too
* Push to quay.io release.yaml + nightly images when succeed
* Handle multiple openshift targets
* Rewrite resolv-yamls.sh, it's still as bad as before and didn't have the
  courage to get my head around it. (just made it work for the new CI)
