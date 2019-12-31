# We can't use UBI here since we need other stuff that's would probably never
# make into UBI
FROM openshift/origin-release:golang-1.13

## TD: to renable
# RUN yum -y update && yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum
RUN yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum

ADD CI/bootstrap/scripts/openshift-install-download.sh  /usr/local/bin/
RUN /usr/local/bin/openshift-install-download.sh
