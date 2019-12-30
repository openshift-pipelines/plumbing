#!/bin/bash
# Simple script so you can backup/restore your simple uploader between nightly reinstall
# We really need to keep the metadata.json to do an uninstall before install,
# since os4 install reaper is buggy and donest delete the DNS name
set -ex

mkdir -p ~/tmp/backup
cd ~/tmp/backup

pod=$(basename $(oc get  pod -n osinstall -l app=uploader -o name))

[[ $1 == save ]] && {
	oc cp -c nginx -n osinstall ${pod}:fileuploads/ fileuploads
}

[[ $1 == restore ]] && {
	oc cp -c nginx fileuploads osinstall/${pod}:
}

[[ $1 == ssh ]] && {
    oc rsh --shell=/bin/bash -c nginx -n osinstall ${pod} $2
}
