#!/bin/bash
set -euo pipefail

# User configuration scripts, not to be run as root.
# Should be run after installation.

# Optional: Install addtional settings for SpackeVim (kjoshi specific)
git clone --recursive https://github.com/kaiwalyajoshi/SpaceVim.d.git
ln -s /home/ubuntu/SpaceVim.d/.SpaceVim.d /home/ubuntu/.SpaceVim.d

#cd ~/go/src/github.com/mesosphere/
#git clone --recursive git@github.com:mesosphere/dkp-insights.git
