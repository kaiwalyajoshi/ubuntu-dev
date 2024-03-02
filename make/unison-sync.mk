
UNISON_OPTS_COMMON :=-batch -auto -watch -repeat 5 -ignore 'BelowPath .idea' -ignore 'BelowPath .local' -ignore 'BelowPath dist' -ignore 'BelowPath pkg/generated'

REPOSITORIES_SOURCE_REPO_BASE := ${HOME}/repositories
REPOSITORIES_TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/repositories

SYNC_CUSTOM_REPO ?= /tmp/non-existing-default-repo

.PHONY: unison-sync-repo
unison-sync-repo: ## Sync main repo
unison-sync-repo:
	$(call print-target)
		unison "${IR}" "ssh://insights-dev-box/${TARGET_REPO}" -prefer "${IR}" $(UNISON_OPTS_COMMON)

.PHONY: unison-reviews-repo
unison-reviews-repo: ## Sync reviews repo
unison-reviews-repo:
	$(call print-target)
		unison "${CR}" "ssh://insights-dev-box//home/$(EC2_INSTANCE_USER)/code-reviews/dkp-insights" -prefer "${CR}" $(UNISON_OPTS_COMMON)

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

.PHONY: unison-custom-repo
unison-custom-repo: ## Sync VSphere Base Template Repo
unison-custom-repo:
	$(call print-target)
	$(shell $(call invoke_unison,forked-repositories/cluster-api-provider-cloud-director))

define invoke_unison
    $(eval $@_REPOSITORY_NAME = $(1))
		echo "unison "${REPOSITORIES_SOURCE_REPO_BASE}/${$@_REPOSITORY_NAME}" "ssh://insights-dev-box/${REPOSITORIES_TARGET_REPO_BASE}/${$@_REPOSITORY_NAME}" -prefer "${REPOSITORIES_SOURCE_REPO_BASE}/${$@_REPOSITORY_NAME}" $(UNISON_OPTS_COMMON)"
endef
