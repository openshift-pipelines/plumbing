# We can't use UBI here since we need other stuff that's would probably never
# make into UBI
FROM openshift/origin-release:golang-1.13

## TODO: Reenable
# RUN yum -y update && yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum
RUN yum -y install python-boto && yum -y clean all && rm -rf /var/cache/yum

ADD CI/bootstrap/scripts/openshift-install-download.sh /usr/local/bin/
ADD CI/bootstrap/scripts/get-github-asset.sh /usr/local/bin/

# Install yq and jq for template manipulation
RUN curl -L -# -o /usr/local/bin/yq `/usr/local/bin/get-github-asset.sh mikefarah/yq linux_amd64` && \
        chmod +x /usr/local/bin/yq

# Download openshift installer
RUN /usr/local/bin/openshift-install-download.sh
