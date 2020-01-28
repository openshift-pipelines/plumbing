#!/usr/bin/env bash
# Chmouel Boudjnah <chmouel@redhat.com>
set -e

targetdir=/usr/local/bin
version=latest

URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${version}

versionnumber=$(curl f -s ${URL}/release.txt |sed -n '/Version:/ { s/.*:[ ]*//; p ;}')

[[ -z ${versionnumber} ]] && {
    echo "Could not detect version"
    exit 1
}

mkdir -p ${targetdir}

case $(uname -o) in
    *Linux)
        platform=linux
        ;;
    Darwin)
        platform=mac
        ;;
    *)
        echo "Could not detect platform: $(uname -o)"
        exit 1
esac

echo -n "Downloading openshift-clients-${version}: "
curl -s -L ${URL}/openshift-client-${platform}-${versionnumber}.tar.gz|tar -xzf- -C ${targetdir} oc kubectl
echo "Done."
echo -n "Downloading openshift-installer-${version}: "
curl -s -L ${URL}/openshift-install-${platform}-${versionnumber}.tar.gz|tar -xzf- -C ${targetdir} openshift-install
echo "Done."
