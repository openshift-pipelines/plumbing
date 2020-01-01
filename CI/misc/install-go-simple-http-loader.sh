#!/usr/bin/env bash
# Install GO SIMPLE Uploader, this assumes you have checked it out in GOPATH

cd $HOME/GIT/go/src/github.com/chmouel/go-simple-uploader/openshift
oc project osinstall 2>/dev/null || oc new-project osinstall
make deploy
