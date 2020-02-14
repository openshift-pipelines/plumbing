# TODOs

## High (POC)
* go over all the TODOs in the code
* Specify release.yaml image by digest instead by tags.
* Create RoleBinding instead of `oc adm policy` thing...
* Add trigger failure status to the github pull request (only slack atm)
* Ensure there is no other pipeline running at the same time.

# Low (post POC)
* Use customize remove those sed variables :(
* Commonalise the image names for the base golang versions across tasks.
* Reevaluate the SKIPPED e2e tests for pipeline and see if we can improve.
* Rewrite resolv-yamls.sh, it's still as bad as before and didn't have the
  courage to get my head around it. (just made it work for the new CI)
* Handle multiple openshift targets
* Stream logs to the log server. (extend: https://github.com/chmouel/go-simple-uploader/ )
* Only generate the bootstrap task (the base task for all others) when a change to the repo is made.
* Move out the large scripts in template to the repository.
* Add buildah to bootstrap and use that so we don't have to install make all the
  time

# Maybe
* Create our own SA, don't use existing....
* Use a [S3 bucket](https://git.io/JexBs) when we do private stuff instead of having to do go-simple-uploader.
  (Altought gsu it works well enough for our use case and can give us anonymous/authenticated as we want)
