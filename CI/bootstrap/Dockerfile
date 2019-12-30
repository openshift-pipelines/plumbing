FROM openshift/origin-release:golang-1.13

RUN dnf install python-boto && dnf clean all

ADD CI/bootstrap/scripts/openshift-install-download.sh  /usr/local/bin/
RUN /usr/local/bin/openshift-install-download.sh

COPY . /workspace/plumbing
