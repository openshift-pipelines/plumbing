# We can't use UBI here since we need other stuff that's would probably never
# make into UBI
FROM centos:latest

## TD: to renable
# RUN yum -y update && yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum
RUN dnf -y install python3 &&  python3 -m pip install awscli && dnf -y clean all && rm -rf /var/cache/yum

ADD CI/bootstrap/scripts/openshift-install-download.sh  /usr/local/bin/
RUN /usr/local/bin/openshift-install-download.sh
