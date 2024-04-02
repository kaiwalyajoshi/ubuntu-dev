.ONESHELL:
.lDEFAULT_GOAL := help

ROOT_DIR ?= $(shell git rev-parse --show-toplevel)

TERRAFORM_OPTS := -var owner=$(shell whoami) -auto-approve

ifneq ("$(wildcard $(CURDIR)/inventory)","")
SYNC_HOST=insights-dev-box
EC2_INSTANCE_USER := ubuntu
EC2_INSTANCE_HOST := $(strip $(shell cat inventory | grep -E "(.*)amazonaws\.com"))
EC2_SSH_KEY := $(shell cat inventory | grep -E ".*\.pem" | cut -d "=" -f 2)
else
SYNC_HOST=P16s.local
EC2_INSTANCE_USER := kjoshi
EC2_INSTANCE_HOST := P16s.local
EC2_SSH_KEY := ~/.ssh/id_ed25519
endif

TARGET_REPO_BASE := /home/$(EC2_INSTANCE_USER)/go/src/github.com/mesosphere
TARGET_REPO := $(TARGET_REPO_BASE)/dkp-insights
MANAGEMENT_KUBECONFIG := $(TARGET_REPO)/artifacts/management.kubeconfig

SSH_OPTS := -i $(EC2_SSH_KEY) -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o ServerAliveInterval=30
SSH_TUNNEL_PORT := 1337

PORT_FORWARD ?= 8888
POSTGRES_PORT_FORWARD ?= 5432
API_PORT_FORWARD ?= 8090

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

define print-target
		@printf "Executing target: \033[36m$@\033[0m\n"
endef

## Rsync based sync routines (deprecated)
#include $(ROOT_DIR)/make/rsync-sync.mk
## Unison based sync routines
include $(ROOT_DIR)/make/unison-sync.mk

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
	tofu init
	tofu apply $(TERRAFORM_OPTS)
	make -C $(ROOT_DIR) populate-ssh-config

.PHONY: destroy
destroy: ## Destroy an EC2 instance
destroy:
	$(call print-target)
	tofu destroy $(TERRAFORM_OPTS)

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
		ForwardAgent yes
		SendEnv GIT_NAME
		SendEnv GIT_EMAIL
		SendEnv GIT_SIGNING_KEY
		SendEnv GITHUB_USERNAME
		SendEnv GITHUB_TOKEN
		SendEnv DOCKER_USERNAME
		SendEnv DOCKER_PASSWORD
		SendEnv PROVIDER_ADMIN_USER
		SendEnv PROVIDER_ADMIN_PASSWORD
		SendEnv TEST_E2E_PRIVATE_KEY
		SendEnv TEST_E2E_PUBLIC_KEY
		SendEnv VCD_REFRESH_TOKEN
	EOF
	echo "Ensure the following is added to ~/.ssh/config:Include $(ROOT_DIR)/ssh-config"
