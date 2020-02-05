FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
# Todo: reenable after pOC
RUN microdnf -y update && microdnf clean all &&  rm -rf /var/cache/yum
COPY %%BASE_BIN%% /ko-app/%%BASE_BIN%%
ENTRYPOINT ["/ko-app/%%BASE_BIN%%"]
