# FAQ

* How do I run this locally from my laptop?

  Just look at the [config.sh.sample](config.sh.sample), collect all the
  credentials needed from there, and run the `start.sh` script. You can then
  use the [`tkn`](github.com/tektoncd/cli) CLI to track the update of the deployment like this :

  ```
  tkn pipeline logs openshift-pipeline-ci -f
  ```

* How do I run a certain task without rerun the full pipeline?

  Just use the `tkn` CLI with the right argument, for example I use this for rerunning the `build-tekton-pipeline` task :

  ```
  k delete -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline.yaml && \
  k create -f $(git rev-parse --show-toplevel)/CI/tasks/bootstrap/build-tektoncd-pipeline.yaml && \
  tkn task start build-tektoncd-pipeline-and-push --showlog \
   --param UPLOADER_HOST=https://uploader.host \
   -i plumbing-git=plumbing-git -i tektoncd-pipeline-git=tektoncd-pipeline-git \
   --serviceaccount builder
  ```

* If you have an error like this :
  ```
  securitycontextconstraints.security.openshift.io/privileged added to: ["system:serviceaccount:ci-openshift-pipelines:builder"]
  ------ Installing catalog tasks
      error: unable to recognize "STDIN": no matches for kind "Task" in version "tekton.dev/v1alpha1"
  ```
  It probably means you don't have tekton installed
