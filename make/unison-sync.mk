UNISON_OPTS_COMMON :=-ui text -batch -auto -watch -repeat 5 -ignore 'BelowPath .idea' -ignore 'BelowPath .local' -ignore 'BelowPath dist' -ignore 'BelowPath pkg/generated'

REPOSITORIES_SOURCE_REPO_BASE := ${HOME}/repositories
REPOSITORIES_TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/repositories

NUTANIX_SOURCE_BASE=${HOME}/nutanix
NUTANIX_TARGET_BASE=/home/$(EC2_INSTANCE_USER)/nutanix

SYNC_CUSTOM_REPO ?= /tmp/non-existing-default-repo

#PREFER_HOST=-prefer "${REPOSITORIES_SOURCE_REPO_BASE}/${$@_REPOSITORY_NAME}"
PREFER_HOST=-prefer "${REPOSITORIES_TARGET_REPO_BASE}/${$@_REPOSITORY_NAME}"

.PHONY: unison-sync-repo
unison-sync-repo: ## Sync main repo
unison-sync-repo:
	$(call print-target)
		unison "${IR}" "ssh://${SYNC_HOST}/${TARGET_REPO}" -prefer "${IR}" $(UNISON_OPTS_COMMON)

.PHONY: unison-reviews-repo
unison-reviews-repo: ## Sync reviews repo
unison-reviews-repo:
	$(call print-target)
		unison "${CR}" "ssh://${SYNC_HOST}//home/$(EC2_INSTANCE_USER)/code-reviews/dkp-insights" -prefer "${CR}" $(UNISON_OPTS_COMMON)

.PHONY: unison-projects-repo
unison-projects-repo: ## Sync projects repo
unison-projects-repo:
	$(call print-target)
	$(shell $(call invoke_unison,dkp-insights))

.PHONY: unison-kib-repo
unison-kib-repo: ## Sync KIB Repo
unison-kib-repo:
	$(call print-target)
	$(shell $(call invoke_unison,konvoy-image-builder))

.PHONY: unison-cappp-repo
unison-cappp-repo: ## Sync CAPPP Repo
unison-cappp-repo:
	$(call print-target)
	$(shell $(call invoke_unison,cluster-api-provider-preprovisioned))

.PHONY: unison-vsphere-base-template-repo
unison-vsphere-base-template-repo: ## Sync VSphere Base Template Repo
unison-vsphere-base-template-repo:
	$(call print-target)
	$(shell $(call invoke_unison,vsphere-base-template))

.PHONY: unison-konvoy-repo
unison-konvoy-repo: ## Sync Konvoy Repo
unison-konvoy-repo:
	$(call print-target)
	$(shell $(call invoke_unison,konvoy2))

.PHONY: unison-cluster-api-provider-cloud-director-repo
unison-cluster-api-provider-cloud-director-repo: ## Sync VSphere Base Template Repo
unison-cluster-api-provider-cloud-director-repo:
	$(call print-target)
	$(shell $(call invoke_unison,cluster-api-provider-cloud-director))

.PHONY: unison-forked-cluster-api-provider-cloud-director-repo
unison-forked-cluster-api-provider-cloud-director-repo: ## Sync VSphere Base Template Repo
unison-forked-cluster-api-provider-cloud-director-repo:
	$(call print-target)
	$(shell $(call invoke_unison,forked-repositories/cluster-api-provider-cloud-director))

.PHONY: unison-kommander-repo
unison-kommander-repo: ## Sync Kommander Repo
unison-kommander-repo:
	$(call print-target)
	$(shell $(call invoke_unison,kommander))

.PHONY: unison-kommander-applications-repo
unison-kommander-applications-repo: ## Sync Kommander-Applications Repo
unison-kommander-applications-repo:
	$(call print-target)
	$(shell $(call invoke_unison,kommander-applications))

.PHONY: unison-dkp-catalog-applications-repo
unison-dkp-catalog-applications-repo: ## Sync DKP Catalogr-Applications Repo
unison-dkp-catalog-applications-repo:
	$(call print-target)
	$(shell $(call invoke_unison,dkp-catalog-applications))

.PHONY: unison-kommander-e2e-repo
unison-kommander-e2e-repo: ## Sync Kommander E2E Repo
unison-kommander-e2e-repo:
	$(call print-target)
	$(shell $(call invoke_unison,kommander-e2e))

.PHONY: unison-custom-repo
unison-custom-repo:  ## Sync repos directory
unison-custom-repo:
	$(call print-target)
	$(shell $(call invoke_unison,$(SYNC_CUSTOM_REPO)))

.PHONY: unison-repositories-directory
unison-repositories-directory:  ## Sync entire repos directory
unison-repositories-directory:
	$(call print-target)
	$(shell $(call invoke_unison,""))

.PHONY: unison-nutanix-directory
unison-nutanix-directory:  ## Sync entire nutanix directory
unison-nutanix-directory:
	$(call print-target)
	$(shell unison "${NUTANIX_SOURCE_BASE}/" "ssh://${SYNC_HOST}/${NUTANIX_TARGET_BASE}/" $(PREFER_HOST) $(UNISON_OPTS_COMMON))

define invoke_unison
    $(eval $@_REPOSITORY_NAME = $(1))
		echo "unison-2.53 "${REPOSITORIES_SOURCE_REPO_BASE}/${$@_REPOSITORY_NAME}" "ssh://${SYNC_HOST}/${REPOSITORIES_TARGET_REPO_BASE}/${$@_REPOSITORY_NAME}"  $(UNISON_OPTS_COMMON)"
endef
