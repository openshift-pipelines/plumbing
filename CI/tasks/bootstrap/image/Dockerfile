# We can't use UBI here since we need other stuff that's would probably never
# make into UBI
FROM openshift/origin-release:golang-1.13

## TODO: Reenable
# RUN yum -y update && yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum
RUN yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum

ADD CI/tasks/bootstrap/image/scripts/openshift-install-download.sh /usr/local/bin/
ADD CI/tasks/bootstrap/image/scripts/get-github-asset.sh /usr/local/bin/

# Install tkn tool which is used in e2e-tests
RUN curl -s -L `/usr/local/bin/get-github-asset.sh tektoncd/cli Linux_x86_64.tar.gz` | \
     tar xzf - -C /usr/local/bin/ --wildcards 'tkn' && \
        chmod +x /usr/local/bin/tkn

# Download openshift installer
RUN /usr/local/bin/openshift-install-download.sh
