#!/bin/bash
set -euo pipefail

# User configuration scripts, not to be run as root.

# Must be run before git clones below.
# Add saner defaults for github.com based repos.
cat >/home/ubuntu/.ssh/config<<EOF
Host github.com
     StrictHostKeyChecking accept-new
EOF

# Optional: Install SpaceVim
curl -sLf https://spacevim.org/install.sh | bash

# Optional: Install addtional settings for SpackeVim (kjoshi specific)
git clone --recursive https://github.com/kaiwalyajoshi/SpaceVim.d.git
ln -s /home/ubuntu/SpaceVim.d/.SpaceVim.d /home/ubuntu/.SpaceVim.d

# Optional: Install Oh-My-Bash
#bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
#cp /home/ubuntu/oh-my-bash.bash /home/ubuntu/.bashrc

# Optional: Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cp -f /home/ubuntu/oh-my-zsh.bash /home/ubuntu/.zshrc


# Everything below must be run after the git clones above

# Generate .gitconfig, modify these as needed.
cat >/home/ubuntu/.gitconfig<<EOF
[user]
  editor = vim
  pager = delta
[commit]
  gpgSign = true
[tag]
  gpgSign = true
[url "git@github.com:"]
  insteadOf = https://github.com/
[fetch]
  recurseSubmodules = true
[delta]
  line-numbers = true
  side-by-side = true
[submodule]
  recurse = true
[color]
  ui = true
  branch = false
[color "diff-highlight"]
  oldNormal = "red bold"
  oldHighlight = "red bold 52"
  newNormal = "green bold"
  newHighlight = "green bold 22"
[color "diff"]
  meta = "11"
  frag = "magenta bold"
  commit = "yellow bold"
  old = "red bold"
  new = "green bold"
  whitespace = "red reverse"
EOF
