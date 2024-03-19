#!/bin/bash
set -euo pipefail

# User configuration scripts, not to be run as root.
# Should be run after installation.

# Optional: Install addtional settings for SpackeVim (kjoshi specific)
git clone --recursive https://github.com/kaiwalyajoshi/SpaceVim.d.git
ln -s /home/ubuntu/SpaceVim.d/.SpaceVim.d /home/ubuntu/.SpaceVim.d

# Create bin dir
mkdir -p ${HOME}/bin

# Add KinD binary
curl -fsSL https://github.com/kubernetes-sigs/kind/releases/download/v0.22.0/kind-linux-amd64 -o ${HOME}/bin/kind
chmod ug+rx ${HOME}/bin/kind

# Add gh binary
curl -fsSL https://github.com/cli/cli/releases/download/v2.45.0/gh_2.45.0_linux_amd64.tar.gz | tar xz -C ${HOME}/bin --strip-components 2 --wildcards gh_2.45.0_linux_amd64/bin/gh

# Add TAM binary
gh release download --repo mesosphere/tam-cli v0.1.1 -p tam-linux-amd64.tar.gz -O - | tar xz -C ${HOME}/bin --wildcards 'tam'

# Add MAWS Binary
gh release download --repo mesosphere/maws 1.0.1 -p maws-linux-amd64.tar.gz -O - | tar xz -C ${HOME}/bin  --wildcards 'maws'

# Set MAWS Config
maws config set url https://aws.production.d2iq.cloud

# Add TAM-CLI Plugin
pushd ${HOME}/repositories
git clone --recursive git@github.com:mesosphere/vcenter-tools.git
pushd vcenter-tools
sudo install ./tam-plugins/tam-plugin-vsphere /usr/local/bin/tam-plugin-vsphere
popd
popd

# Set TAM Config.
tam config set url https://tam.production.d2iq.cloud

# Echo out public key
mkdir -p ${HOME}/.ssh
echo -E ${GIT_SIGNING_KEY} > ${HOME}/.ssh/id_ed25519.pub
echo -E ${TEST_E2E_PRIVATE_KEY} > ${HOME}/.ssh/test-e2e.private
echo -E ${TEST_E2E_PUBLIC_KEY} > ${HOME}/.ssh/test-e2e.public

chmod -R og-rwx ${HOME}/.ssh/*

ssh-add ${HOME}/.ssh/test-e2e.private

#cd ~/go/src/github.com/mesosphere/
#git clone --recursive git@github.com:mesosphere/dkp-insights.git
