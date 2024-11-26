#!/bin/bash

# Software or configuration to be installed as root user.

set -euo pipefail

# Override this user as needed.
USER=${USER:-"ubuntu"}

# Add updated git to PPA
sudo NEEDRESTART_MODE=a add-apt-repository ppa:git-core/ppa -y

export NEEDRESTART_MODE=a

apt-get update

apt-get install -y \
  curl \
  git \
  gnupg2 \
  make \
  pbzip2 \
  python3 \
  python3-pip \
  python3-venv \
  tar \
  unzip \
  iotop \
  fio \
  sysstat \
  strace \
  sshuttle \
  xdg-utils \
  jq \
  fzf \
  silversearcher-ag \
  tig \
  vim-gtk3 \
  tree \
  unison \
  zsh

# Docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

usermod -aG docker "${USER}"

# Delta Pager for Git Diffs
wget https://github.com/dandavison/delta/releases/download/0.16.5/git-delta-musl_0.16.5_amd64.deb
sudo dpkg -i git-delta-musl_0.16.5_amd64.deb
rm git-delta-musl_0.16.5_amd64.deb

# Pre-Commit and NodeJS (for some reason).
apt-get install -y \
    nodejs \
    npm \
    python3

# Add pip and pre-commit
pip install --upgrade pip
pip install pre-commit

mkdir -p "/home/${USER}/go/src/github.com/mesosphere"
chown -R "${USER}:${USER}" "/home/${USER}/go"

mkdir -p "/home/${USER}/code-reviews"
chown -R "${USER}:${USER}" "/home/${USER}/code-reviews"

mkdir -p "/home/${USER}/repositories"
chown -R "${USER}:${USER}" "/home/${USER}/repositories"

# Fix pod errors due to “too many open files” (https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files)
sysctl fs.inotify.max_user_watches=524288
sysctl fs.inotify.max_user_instances=512

# NOTE: Add these to your local ~/.ssh/config, for this to work.
echo "AcceptEnv GIT_NAME" >> /etc/ssh/sshd_config
echo "AcceptEnv GIT_EMAIL" >> /etc/ssh/sshd_config
echo "AcceptEnv GIT_SIGNING_KEY" >> /etc/ssh/sshd_config
echo "AcceptEnv GITHUB_USERNAME" >> /etc/ssh/sshd_config
echo "AcceptEnv GITHUB_TOKEN" >> /etc/ssh/sshd_config
echo "AcceptEnv DOCKER_USERNAME" >> /etc/ssh/sshd_config
echo "AcceptEnv DOCKER_PASSWORD" >> /etc/ssh/sshd_config
echo "AcceptEnv PROVIDER_ADMIN_USER" >> /etc/ssh/sshd_config
echo "AcceptEnv PROVIDER_ADMIN_PASSWORD" >> /etc/ssh/sshd_config
echo "AcceptEnv TEST_E2E_PRIVATE_KEY" >> /etc/ssh/sshd_config
echo "AcceptEnv TEST_E2E_PUBLIC_KEY" >> /etc/ssh/sshd_config
echo "AcceptEnv VCD_REFRESH_TOKEN" >> /etc/ssh/sshd_config

# Change user shell to zsh
chsh -s /usr/bin/zsh "${USER}"

# Restart ssh service
systemctl restart sshd.service
