# Things you should really configure if testing locally
OUTPUT_DIR=/workspace/build-pipelines/
PIPELINE_REPOSITORY=/workspace/tektoncd-pipeline-git

# If you are testing it on osx you can override it with BUILDAH=docker
BUILDAH := buildah

# TODO: remove this REGISTRY URL to something else
REGISTRY_URL=default-route-openshift-image-registry.apps.samchmou2.devcluster.openshift.com

# The addons images which means shipped in ./vendor files and not in ./cmd
ADDN_IMAGES=./vendor/github.com/GoogleCloudPlatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher

# The image which has extras, we are going to use `Dockerfile.extras` for it
# instead of the very minimal `Dockerfiles`
IMAGES_EXTRAS=creds-init git-init # the images that needs extra cares

# This would get all binary from cmd/ so no need to specify them manually :)
ALL_BINARIES=$(wildcard $(PIPELINE_REPOSITORY)/cmd/*)

build_binary: ## Build TektonCD pipelines binaries
	@echo "Building binaries..."
	@mkdir -p $(OUTPUT_DIR)/bin
	@set -e;pushd $(PIPELINE_REPOSITORY) >/dev/null &&  \
		env GOBIN=$(OUTPUT_DIR)/bin \
		    go install $(PIPELINE_REPOSITORY)/cmd/* $(ADDN_IMAGES) ; \
	popd >/dev/null

create_dockerfiles: ## Create Dockerfiles for binaries, it usually need to be run after build_binary but not enforced
	@echo "Creating dockerfiles"
	@set -e;for cmd in $(ALL_BINARIES) $(ADDN_IMAGES);do \
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

container_build: ## Use buildah to start building the containers
	@echo "Building containers..."
	@set -e; pushd $(OUTPUT_DIR);\
	  for dfile in */;do \
		cd $${dfile};\
			$(BUILDAH) bud -t $(REGISTRY_URL)/`basename $$dfile` -f Dockerfile . ;\
		cd .. ;\
	  done ;\
	popd >/dev/null

container_push: ## Use buildah to push the containers to the $REGISTRY_URL
	@echo "Pushing containers..."
	@set -e ;pushd $(OUTPUT_DIR);\
	  for dfile in */;do \
		cd $${dfile};\
			$(BUILDAH) push --tls-verify=false $(REGISTRY_URL)/`basename $$dfile` docker://$(REGISTRY_URL)/`basename $$dfile` ;\
		cd .. ;\
	  done ;\
	popd >/dev/null

clean: ## Clean our generated artifacts
	@rm -rf $(OUTPUT_DIR)

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build_binary create_dockerfiles container_build clean
