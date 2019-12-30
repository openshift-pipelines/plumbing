FROM openshift/origin-release:golang-1.13

RUN yum -y update && yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum

ADD CI/bootstrap/scripts/openshift-install-download.sh  /usr/local/bin/
RUN /usr/local/bin/openshift-install-download.sh

COPY . /plumbing
