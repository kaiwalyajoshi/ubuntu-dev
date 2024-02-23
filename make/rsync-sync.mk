SOURCE_REPO := ${IR}
CODE_REVIEWS_SOURCE_REPO := ${CR}
PROJECTS_SOURCE_REPO := ${PR}

PROJECTS_TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/repositories
CODE_REVIEWS_TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/code-reviews

AI_NAVIGATOR_SOURCE_REPO := ${HOME}/repositories/ai-navigator-cluster-info-agent
KIB_SOURCE_REPO := ${HOME}/repositories/konvoy-image-builder
CAPPP_SOURCE_REPO := ${HOME}/repositories/cluster-api-provider-preprovisioned
VSPHERE_BASE_TEMPLATE_SOURCE_REPO := ${HOME}/repositories/vsphere-base-template
KONVOY_SOURCE_REPO := ${HOME}/repositories/konvoy2

RSYNC_OPTS_COMMON := -rav --exclude .idea --exclude .local --exclude artifacts --exclude dist --exclude pkg/generated -e "ssh $(SSH_OPTS)"
RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(TARGET_REPO_BASE)
PROJECTS_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(PROJECTS_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)
CODE_REVIEWS_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(CODE_REVIEWS_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(CODE_REVIEWS_TARGET_REPO_BASE)
AI_NAVIGATOR_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(AI_NAVIGATOR_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)
KIB_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(KIB_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)
CAPPP_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(CAPPP_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)
VSPHERE_BASE_TEMPLATE_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(VSPHERE_BASE_TEMPLATE_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)
KONVOY_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(KONVOY_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)

.PHONY: rsync-repo
rsync-repo: ## Start one-way synchronization of the $(SOURCE_REPO) to the remote host
rsync-repo:
	$(call print-target)
	rsync $(RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(SOURCE_REPO) | xargs -I{} rsync $(RSYNC_OPTS)

.PHONY: rsync-review-repo
rsync-review-repo: ## Start one-way synchronization of the $(CODE_REVIEWS_SOURCE_REPO) to the remote host
rsync-review-repo:
	$(call print-target)
	rsync $(CODE_REVIEWS_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(CODE_REVIEWS_SOURCE_REPO) | xargs -I{} rsync $(CODE_REVIEWS_RSYNC_OPTS)

.PHONY: rsync-projects-repo
rsync-projects-repo: ## Start one-way synchronization of the $(CODE_REVIEWS_SOURCE_REPO) to the remote host
rsync-projects-repo:
	$(call print-target)
	rsync $(PROJECTS_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(PROJECTS_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)

.PHONY: rsync-ai-navigator-repo
rsync-ai-navigator-repo: ## Start one-way synchronization of the $(AI_NAVIGATOR_SOURCE_REPO) to the remote host
rsync-ai-navigator-repo:
	$(call print-target)
	rsync $(AI_NAVIGATOR_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(AI_NAVIGATOR_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)

.PHONY: rsync-kib-repo
rsync-kib-repo: ## Start one-way synchronization of the $(KIB_SOURCE_REPO) to the remote host
rsync-kib-repo:
	$(call print-target)
	rsync $(KIB_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(KIB_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)

.PHONY: rsync-cappp-repo
rsync-cappp-repo: ## Start one-way synchronization of the $(CAPPP_SOURCE_REPO) to the remote host
rsync-cappp-repo:
	$(call print-target)
	rsync $(CAPPP_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(CAPPP_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)

.PHONY: rsync-vsphere-base-template-repo
rsync-vsphere-base-template-repo: ## Start one-way synchronization of the $(VSPHERE_BASE_TEMPLATE_SOURCE_REPO) to the remote host
rsync-vsphere-base-template-repo:
	$(call print-target)
	rsync $(VSPHERE_BASE_TEMPLATE_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(VSPHERE_BASE_TEMPLATE_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)

.PHONY: rsync-konvoy-repo
rsync-konvoy-repo: ## Start one-way synchronization of the $(KONVOY_SOURCE_REPO) to the remote host
rsync-konvoy-repo:
	$(call print-target)
	rsync $(KONVOY_RSYNC_OPTS)
	fswatch --one-per-batch --recursive --latency 1 $(KONVOY_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)
