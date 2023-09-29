.ONESHELL:
.lDEFAULT_GOAL := help

ROOT_DIR ?= $(shell git rev-parse --show-toplevel)
SOURCE_REPO := $(IR)
PROJECTS_SOURCE_REPO := ${PR}
CODE_REVIEWS_SOURCE_REPO := ${CR}

EC2_INSTANCE_USER := ubuntu

TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/go/src/github.com/mesosphere
TARGET_REPO := $(TARGET_REPO_BASE)/dkp-insights
MANAGEMENT_KUBECONFIG := $(TARGET_REPO)/artifacts/management.kubeconfig

PROJECTS_TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/repositories
CODE_REVIEWS_TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/code-reviews

TERRAFORM_OPTS := -var owner=$(shell whoami) -auto-approve

ifneq ("$(wildcard $(CURDIR)/inventory)","")
EC2_INSTANCE_HOST := $(strip $(shell cat inventory | grep -E "(.*)amazonaws\.com"))
EC2_SSH_KEY := $(shell cat inventory | grep -E ".*\.pem" | cut -d "=" -f 2)
endif

SSH_OPTS := -i $(ROOT_DIR)/$(EC2_SSH_KEY) -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=30

SSH_TUNNEL_PORT := 1337
RSYNC_OPTS_COMMON := -rav --exclude .idea --exclude .local --exclude artifacts --exclude dist --exclude pkg/generated -e "ssh $(SSH_OPTS)"
RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(TARGET_REPO_BASE)
PROJECTS_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(PROJECTS_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(PROJECTS_TARGET_REPO_BASE)
CODE_REVIEWS_RSYNC_OPTS := $(RSYNC_OPTS_COMMON) $(CODE_REVIEWS_SOURCE_REPO) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST):$(CODE_REVIEWS_TARGET_REPO_BASE)

PORT_FORWARD ?= 8888

POSTGRES_PORT_FORWARD ?= 5432
API_PORT_FORWARD ?= 8090

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

define print-target
		@printf "Executing target: \033[36m$@\033[0m\n"
endef

.PHONY: sync-repo
sync-repo: ## Start one-way synchronization of the $(SOURCE_REPO) to the remote host
sync-repo:
	$(call print-target)
	# Perform initial sync
	rsync $(RSYNC_OPTS)
	# Watch for changes and sync
	fswatch --one-per-batch --recursive --latency 1 $(SOURCE_REPO) | xargs -I{} rsync $(RSYNC_OPTS)

.PHONY: sync-review-repo
sync-review-repo: ## Start one-way synchronization of the $(CODE_REVIEWS_SOURCE_REPO) to the remote host
sync-review-repo:
	$(call print-target)
	# Perform initial sync
	rsync $(CODE_REVIEWS_RSYNC_OPTS)
	# Watch for changes and sync
	fswatch --one-per-batch --recursive --latency 1 $(CODE_REVIEWS_SOURCE_REPO) | xargs -I{} rsync $(CODE_REVIEWS_RSYNC_OPTS)

.PHONY: sync-projects-repo
sync-projects-repo: ## Start one-way synchronization of the $(CODE_REVIEWS_SOURCE_REPO) to the remote host
sync-projects-repo:
	$(call print-target)
	# Perform initial sync
	rsync $(PROJECTS_RSYNC_OPTS)
	# Watch for changes and sync
	fswatch --one-per-batch --recursive --latency 1 $(PROJECTS_SOURCE_REPO) | xargs -I{} rsync $(PROJECTS_RSYNC_OPTS)

.PHONY: tunnel
tunnel: ## Create SSH tunnel to the remote instance
tunnel:
	$(call print-target)
	ssh $(SSH_OPTS) -D $(SSH_TUNNEL_PORT) -f -C -q -N $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST)

.PHONY: dashboard
dashboard: ## Load kommander dashboard
dashboard: tunnel
dashboard:
	$(call print-target)
	@echo Obtaining DKP credentials...
	@ssh $(SSH_OPTS) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST) "KUBECONFIG=$(MANAGEMENT_KUBECONFIG) kubectl -n kommander get secret dkp-credentials -o go-template='{{ \"\n\"}}Username: {{.data.username|base64decode}}{{ \"\n\"}}Password: {{.data.password|base64decode}}{{ \"\n\"}}'"
	@echo "---------------------------------------------------"
	@echo Launching Kommander Dashboard...
	@xdg-open $(shell ssh $(SSH_OPTS) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST) "KUBECONFIG=$(MANAGEMENT_KUBECONFIG) kubectl -n kommander get kommanderclusters host-cluster -o go-template='https://{{.status.ingress.address}}/dkp/kommander/dashboard'")

.PHONY: connect
connect: ## Connect to the remote instance
connect:
	$(call print-target)
	ssh $(SSH_OPTS) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST)

.PHONY: create
create: ## Create an EC2 instance with Terraform
create:
	$(call print-target)
	terraform init
	terraform apply $(TERRAFORM_OPTS)
	make -C $(ROOT_DIR) populate-ssh-config

.PHONY: destroy
destroy: ## Destroy an EC2 instance
destroy:
	$(call print-target)
	terraform destroy $(TERRAFORM_OPTS)

.PHONY: clean
clean: ## Delete all Terraform State and SSH Keys.
clean:
	$(call print-target)
	rm -rf .terraform* *.pem terraform.tfstate* ssh-config

.PHONY: port-forward
port-forward: ## Port-forward ports from the EC2 Instance
port-forward:
	$(call print-target)
	ssh $(SSH_OPTS) -N -L $(PORT_FORWARD):localhost:$(PORT_FORWARD) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST)

.PHONY: postgres-port-forward
postgres-port-forward: ## Port-forward Postgres ports from the EC2 Instance
postgres-port-forward:
	$(call print-target)
	ssh $(SSH_OPTS) -N -L $(POSTGRES_PORT_FORWARD):localhost:$(POSTGRES_PORT_FORWARD) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST) &

.PHONY: api-port-forward
api-port-forward: ## Port-forward API ports from the EC2 Instance
api-port-forward:
	$(call print-target)
	ssh $(SSH_OPTS) -N -L $(API_PORT_FORWARD):localhost:$(API_PORT_FORWARD) $(EC2_INSTANCE_USER)@$(EC2_INSTANCE_HOST) &

.PHONY: populate-ssh-config
populate-ssh-config:
populate-ssh-config: ## Generate and populate a ssh config in the current folder. (See README)
	$(call print-target)
	cat << EOF >$(ROOT_DIR)/ssh-config
	Host insights-dev-box
		HostName $(EC2_INSTANCE_HOST)
		IdentityFile $(ROOT_DIR)/$(EC2_SSH_KEY)
		IdentitiesOnly yes
		StrictHostKeyChecking accept-new
		ServerAliveInterval 30
		User $(EC2_INSTANCE_USER)
	EOF
	echo "Ensure the following is added to ~/.ssh/config:Include $(ROOT_DIR)/ssh-config"


