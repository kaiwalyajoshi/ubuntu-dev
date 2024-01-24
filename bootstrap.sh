#!/bin/bash
set -euox pipefail

export USE_KIND_CLUSTERS=true
export INSIGHTS_NAMESPACE=kommander
export SKIP_AWS_CREDENTIALS=true

cd "${IR}"

# Install dependencies 
make install-kind
make install-kubectl
make install-helm
make install-aws-cli

# Renew docker credentials
make configure-docker-credentials

# Create Kind cluster
./hack/create-environments/create-environments.sh create-management-cluster

# Create a symlink for the backend cluster config to point to the management cluster
./hack/create-environments/create-environments.sh create-backend-cluster

# Install Kommander
./hack/create-environments/create-environments.sh install-kommander

# Install Insights Snapshot
make kind-install-helm-management-snapshot
make kind-install-helm-backend-snapshot
