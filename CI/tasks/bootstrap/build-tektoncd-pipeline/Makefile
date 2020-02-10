# Things you should really configure if testing locally
OUTPUT_DIR := /workspace/build-pipelines/
PIPELINE_REPOSITORY := /workspace/tektoncd-pipeline-git

# If you are testing it on osx you can override it with BUILDAH=docker
BUILDAH := buildah

REGISTRY_URL := quay.io/openshift-pipeline/ci
TARGET_REGISTRY_URL := quay.io/openshift-pipeline/nightly
PROJECT_IMAGE_PREFIX := tektoncd-pipelines

# The addons images which means shipped in ./vendor files and not in ./cmd
ADDN_IMAGES=./vendor/github.com/GoogleCloudPlatform/cloud-builders/gcs-fetcher/cmd/gcs-fetcher

# Special images that are special
SNOWFLAKES_IMAGES=nop

# The image which has extras, we are going to use `Dockerfile.extras` for it
# instead of the very minimal `Dockerfiles`
IMAGES_EXTRAS=creds-init git-init # the images that needs extra cares

# This would get all binary from cmd/ so no need to specify them manually :)
ALL_BINARIES=$(wildcard $(PIPELINE_REPOSITORY)/cmd/*)

build_binary: ## Build TektonCD pipelines binaries
	echo "Building binaries..."
	mkdir -p $(OUTPUT_DIR)/bin
	@set -xe ;[[ "$(PROJECT_NAME)XXX" != XXX ]] && prefix=$(PROJECT_NAME) || prefix=$(PIPELINE_REPOSITORY) ; \
		pushd $(PIPELINE_REPOSITORY) >/dev/null && \
		for binary in $(ALL_BINARIES);do all="$$all $$prefix/cmd/$$(basename $$binary)"; done ; \
		for binary in $(ADDN_IMAGES);do all="$$all $$binary"; done ; \
		env CGO_ENABLED=0 GOBIN=/workspace/output/bin go install -mod=vendor $$all

repush_binary: ## Take the images from REGISTRY_URL and push it to TARGET_REGISTRY_URL
	@set -xe;for cmd in $(ALL_BINARIES) $(ADDN_IMAGES) $(SNOWFLAKES_IMAGES);do \
		bcmd=`basename $$cmd` ;\
		buildah pull $(REGISTRY_URL):$$bcmd && \
		buildah tag $(REGISTRY_URL):$$bcmd $(TARGET_REGISTRY_URL):$$bcmd && \
		buildah push $(TARGET_REGISTRY_URL):$$bcmd ;\
		done

create_dockerfiles: ## Create Dockerfiles for binaries, it usually need to be run after build_binary but not enforced
	@echo "Creating dockerfiles"
	@set -xe;for cmd in $(ALL_BINARIES) $(ADDN_IMAGES);do \
		bcmd=`basename $$cmd` ;\
		for extra in $(IMAGES_EXTRAS);do \
			[[ $$bcmd == $${extra} ]] && break || extra="" ; \
		done ;\
		mkdir -p $(OUTPUT_DIR)/$$bcmd/ ;\
		dockerfile=Dockerfile ; \
		[[ -n $$extra ]] && { \
			cp -v uidwrapper $(OUTPUT_DIR)/$$bcmd/uidwrapper ;\
			dockerfile=Dockerfile.extras  ;\
		} ;\
		echo "${dockerfile} => $(OUTPUT_DIR)/$$bcmd/Dockerfile" ;\
		sed -e "s,%%BASE_BIN%%,$$bcmd,g" $$dockerfile > \
			$(OUTPUT_DIR)/$$bcmd/Dockerfile ;\
		mv $(OUTPUT_DIR)/bin/$$bcmd $(OUTPUT_DIR)/$$bcmd/ ;\
	done
	@rmdir $(OUTPUT_DIR)/bin

	@for sf in $(SNOWFLAKES_IMAGES);do \
		mkdir -p $(OUTPUT_DIR)/$$sf/ ;\
		cp -v Dockerfile.$$sf $(OUTPUT_DIR)/$$sf/Dockerfile ;\
	done

container_build: ## Use buildah to start building the containers
	@echo "Building containers..."
	@set -xe; pushd $(OUTPUT_DIR);\
	  for dfile in */;do \
		cd $${dfile};\
			$(BUILDAH) bud -t $(REGISTRY_URL):$(PROJECT_IMAGE_PREFIX)-`basename $$dfile` -f Dockerfile . ;\
		cd .. ;\
	  done ;\
	popd >/dev/null

container_push: ## Use buildah to push the containers to the $REGISTRY_URL
	@echo "Pushing containers..."
	@set -xe ;pushd $(OUTPUT_DIR);\
	  for dfile in */;do \
		cd $${dfile};\
			$(BUILDAH) push $(REGISTRY_URL):$(PROJECT_IMAGE_PREFIX)-`basename $$dfile` ;\
		cd .. ;\
	  done ;\
	popd >/dev/null

clean: ## Clean our generated artifacts
	@rm -rf $(OUTPUT_DIR)

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build_binary create_dockerfiles container_build clean
