* If you have an error like this :
```
securitycontextconstraints.security.openshift.io/privileged added to: ["system:serviceaccount:ci-openshift-pipelines:builder"]
------ Installing catalog tasks
error: unable to recognize "STDIN": no matches for kind "Task" in version "tekton.dev/v1alpha1"
```
  It probabkly means you don't have tekton installed

* How do I run a certain task without rerun the full pipline?

  Just use the `tkn` cli with the right argument, for example I use this for rerunning the `build-tekton-pipeline` task :

  ```
  k delete -f $(git rev-parse --show-toplevel)/CI/tasks/build-tektoncd-pipeline.yaml && \
  k create -f $(git rev-parse --show-toplevel)/CI/tasks/build-tektoncd-pipeline.yaml && \
  tkn task start build-tektoncd-pipeline-and-push --showlog \
   --param UPLOADER_HOST=http://$(oc get route -n osinstall uploader -o jsonpath={.spec.host}) \
   -i plumbing-git=plumbing-git -i tektoncd-pipeline-git=tektoncd-pipeline-git \
   --serviceaccount builder
  ```
