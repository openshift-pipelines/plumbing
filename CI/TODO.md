* Only generate the bootstrap task (the base task for all others) when a change to the repo is made.
* Move out the large scripts in template to the repository.
* Stream logs to the log server. (extend: https://github.com/chmouel/go-simple-uploader/ )
* Convert base image to CentOS, we are using golang when it's not needed for the base image
* Commonalize the image names for the base golang versions across tasks.
