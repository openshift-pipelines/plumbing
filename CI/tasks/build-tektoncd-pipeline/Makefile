# Things you should really configure if testing locally
OUTPUT_DIR=/workspace/build-pipelines/
PIPELINE_REPOSITORY=/workspace/tektoncd-pipeline-git

CGO_ENABLED=0
ADDN_IMAGES=./vendor/github.com/GoogleCloudPlatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher
IMAGES_EXTRAS=creds-init git-init
ALL_BINARIES=$(wildcard $(PIPELINE_REPOSITORY)/cmd/*)
# TODO: proper
REGISTRY_URL=default-route-openshift-image-registry.apps.samchmou2.devcluster.openshift.com

# If you are testing it on osx you can override it with BUILDAH=docker
BUILDAH := buildah

build_binary:
	@echo "Building binaries..."
	@mkdir -p $(OUTPUT_DIR)/bin
	@pushd $(PIPELINE_REPOSITORY) >/dev/null &&  \
		env GO111MODULE=off GOBIN=$(OUTPUT_DIR)/bin \
			go install $(PIPELINE_REPOSITORY)/cmd/* $(ADDN_IMAGES) ; \
	popd >/dev/null

create_dockerfiles: build_binary
	@echo "Creating dockerfiles"
	@for cmd in $(ALL_BINARIES) $(ADDN_IMAGES);do \
		bcmd=`basename $$cmd` ;\
		for extra in $(IMAGES_EXTRAS);do \
			[[ $$bcmd == $${extra} ]] && break || extra="" ; \
		done ;\
		mkdir -p $(OUTPUT_DIR)/$$bcmd/ ;\
		dockerfile=Dockerfile ; \
		[[ -n $$extra ]] && { \
			cp uidwrapper $(OUTPUT_DIR)/$$bcmd/uidwrapper ;\
			dockerfile=Dockerfile.extras  ;\
		} ;\
		sed -e "s,%%BASE_BIN%%,$$bcmd,g" $$dockerfile > \
			$(OUTPUT_DIR)/$$bcmd/Dockerfile ;\
		mv $(OUTPUT_DIR)/bin/$$bcmd  $(OUTPUT_DIR)/$$bcmd/ ;\
	done
	@rmdir $(OUTPUT_DIR)/bin

container_build: create_dockerfiles
	@echo "Building containers..."
	@pushd $(OUTPUT_DIR); \
	set -x ;\
	  for dfile in */;do \
		cd $${dfile};\
			$(BUILDAH) build -t $(REGISTRY_URL)/`basename $$dfile` -f Dockerfile . ;\
		cd .. ;\
	  done ;\
	popd >/dev/null

clean:
	@rm -rf $(OUTPUT_DIR)

.PHONY: build_binary create_dockerfiles container_build clean
