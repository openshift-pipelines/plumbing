#!/bin/bash
# Install GO SIMPLE Uploader, this assumes you have checked it out in GOPATH

cd $HOME/GIT/go/src/github.com/chmouel/go-simple-uploader/openshift
oc new-project osinstall 2>/dev/null || oc project osinstall
make deploy
