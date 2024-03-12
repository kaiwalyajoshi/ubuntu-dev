#!/bin/bash
set -euo pipefail

# User configuration scripts, not to be run as root.
# Should be run after installation.

# Optional: Install addtional settings for SpackeVim (kjoshi specific)
git clone --recursive https://github.com/kaiwalyajoshi/SpaceVim.d.git
ln -s /home/ubuntu/SpaceVim.d/.SpaceVim.d /home/ubuntu/.SpaceVim.d

# Create bin dir
mkdir -p ${HOME}/bin

# Add gh binary
curl -fsSL https://github.com/cli/cli/releases/download/v2.45.0/gh_2.45.0_linux_amd64.tar.gz | tar xz -C ${HOME}/bin --strip-components 2 --wildcards gh_2.45.0_linux_amd64/bin/gh

# Add TAM binary
gh release download --clobber --repo mesosphere/tam-cli v0.1.1 -p tam-linux-amd64.tar.gz -O - | tar xz -C ${HOME}/bin --wildcards 'tam'

#cd ~/go/src/github.com/mesosphere/
#git clone --recursive git@github.com:mesosphere/dkp-insights.git
