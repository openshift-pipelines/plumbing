# TODOs

## High (POC)
* Make sure containers are updated with latest packages (currently disabled for iterations).
* Commonalise the image names for the base golang versions across tasks.
* Push to quay.io release.yaml + nightly images when succeed
* Move all settings to one place
* Document flow and structure

# Low (post POC)
* Reevaluate the SKIPPED e2e tests for pipeline and see if we can improve.
* Rewrite resolv-yamls.sh, it's still as bad as before and didn't have the
  courage to get my head around it. (just made it work for the new CI)
* Handle multiple openshift targets
* Stream logs to the log server. (extend: https://github.com/chmouel/go-simple-uploader/ )
* Only generate the bootstrap task (the base task for all others) when a change to the repo is made.
* Move out the large scripts in template to the repository.

# Maybe
* Create our own SA, don't use existing....
* Use a [S3 bucket](https://git.io/JexBs) when we do private stuff instead of having to do go-simple-uploader.
  (Altought gsu it works well enough for our use case and can give us anonymous/authenticated as we want)
