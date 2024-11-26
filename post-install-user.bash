#!/bin/bash
set -euo pipefail

# User configuration scripts, not to be run as root.
# Should be run after installation.
pushd ${HOME}

echo "Configure SpaceVim"
# if [[ ! -d "/home/${HOME}/.SpaceVim.d" ]]; then
  ## Optional: Install addtional settings for SpaceVim (kjoshi specific)
  # git clone --recursive https://github.com/kaiwalyajoshi/SpaceVim.d.git
  # ln -s ${HOME}/SpaceVim.d/.SpaceVim.d ${HOME}/.SpaceVim.d
# fi
#
echo "Configure ASDF"
# Check if asdf exists
if [[ ! -d "${HOME}/.asdf" ]]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  set +e
  grep -q 'asdf.sh' "${HOME}/.zshrc"
  if [[ $? -ne 0 ]]; then
    echo ". ${HOME}/.asdf/asdf.sh" >> "${HOME}/.zshrc"
  fi
  set -e
fi

# Check if GNU Make 4.3 exists
echo "Configure GNU Make 4.3"
if [[ ! -x "${HOME}/dev_tools/gnumake/$(uname -s)/$(uname -m)/gnumake-4.3/bin/make" ]]; then
  INSTALL_ROOT=${HOME}/dev_tools/gnumake/$(uname -s)/$(uname -m)
  mkdir -p "${INSTALL_ROOT}"
  pushd "${INSTALL_ROOT}"
    wget https://ftp.gnu.org/gnu/make/make-4.3.tar.gz
    tar -xvf make-4.3.tar.gz
    pushd make-4.3
      export INSTALL_PREFIX="${INSTALL_ROOT}/gnumake-4.3"
      mkdir -p ${INSTALL_PREFIX}
      ./configure --prefix=${INSTALL_PREFIX}
      make
      make install
    popd
  popd
fi

echo "Configure Oh-My-Zsh"
# Check if asdf exists
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# Create bin dir
mkdir -p ${HOME}/bin

# Set MAWS Config
#maws config set url https://aws.production.d2iq.cloud

# Echo out public key
mkdir -p ${HOME}/.ssh
echo ${GIT_SIGNING_KEY} > ${HOME}/.ssh/id_ed25519.pub
chmod -R og-rwx ${HOME}/.ssh/*

#cd ~/go/src/github.com/mesosphere/
#git clone --recursive git@github.com:mesosphere/dkp-insights.git

popd
