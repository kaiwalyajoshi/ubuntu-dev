# Other aliases.
alias suod='sudo'
alias vimr='vim -R'
alias gerp='grep'
alias dockr='docker'
alias docs='dcos'
alias k='kubectl'
alias knovoy='konvoy'
alias hisotry='history'
alias rsearch='history | grep'
alias rserach='history | grep'
alias watch='watch '
alias gut='git'
alias gti='git'
alias mkae='make'
alias cls='tput reset'
#alias vim='nvim'

#export GOROOT=/usr/local/go
export GOROOT=$(dirname $(dirname $(asdf which go)))
export GOPATH="$HOME/go"
export GO111MODULE=auto

# Code Reviews.
mkdir -p ${HOME}/code-reviews
# Pull Requests.
mkdir -p ${HOME}/repositories

export FR=${HOME}/repositories/forked-repositories
export RP=${HOME}/repositories/dkp-insights-replay
export KD=${HOME}/repositories/kommander
export NR=${HOME}/repositories/nkp-pulse

# DKP-Insights Related repositories.
export FIR=${HOME}/repositories/forked-repositories/dkp-insights
export CR=${HOME}/code-reviews/dkp-insights
export PR=${GOPATH}/src/github.com/mesosphere/dkp-insights
export IR=${HOME}/repositories/dkp-insights
export PATH=${IR}/.local/tools:${PATH}

export DEV_BOX=${FR}/ubuntu-dev

export BACKEND_KUBECONFIG=${IR}/artifacts/backend.kubeconfig
export MANAGEMENT_KUBECONFIG=${IR}/artifacts/management.kubeconfig
export DAILY_KUBECONFIG=${HOME}/repositories/daily-cluster/dkp-daily.conf
export SOAK_KUBECONFIG=${HOME}/repositories/soak-cluster/soak-cluster.conf
export KOMMANDER_TEST_KUBECONFIG=${KD}/kubeconfig-kommander-testing

alias b_k="KUBECONFIG=${BACKEND_KUBECONFIG} kubectl"
alias m_k="KUBECONFIG=${MANAGEMENT_KUBECONFIG} kubectl"
alias d_k="KUBECONFIG=${DAILY_KUBECONFIG} kubectl"
alias s_k="KUBECONFIG=${SOAK_KUBECONFIG} kubectl"
alias k_k="KUBECONFIG=${KOMMANDER_TEST_KUBECONFIG} kubectl"

alias b_k9s="KUBECONFIG=${BACKEND_KUBECONFIG} k9s"
alias m_k9s="KUBECONFIG=${MANAGEMENT_KUBECONFIG} k9s"
alias d_k9s="KUBECONFIG=${DAILY_KUBECONFIG} k9s"
alias s_k9s="KUBECONFIG=${SOAK_KUBECONFIG} k9s"
alias k_k9s="KUBECONFIG=${KOMMANDER_TEST_KUBECONFIG} k9s"

alias m_dkp="KUBECONFIG=${MANAGEMENT_KUBECONFIG} dkp"
alias b_dkp="KUBECONFIG=${BACKEND_KUBECONFIG} dkp"
alias d_dkp="KUBECONFIG=${DAILY_KUBECONFIG} dkp"
alias s_dkp="KUBECONFIG=${SOAK_KUBECONFIG} dkp"
alias k_dkp="KUBECONFIG=${KOMMANDER_TEST_KUBECONFIG} dkp"

alias ag='ag --hidden --color-path="1;1;36" --color-match="30;45"'

# Use the build Make 4.3
export PATH=${HOME}/dev_tools/gnumake/$(uname -s)/$(uname -m)/gnumake-4.3/bin:${PATH}
export MANPATH=${HOME}/dev_tools/gnumake/$(uname -s)/$(uname -m)/gnumake-4.3/share/man/man1:$(manpath)

export PATH=${GOROOT}/bin:${PATH}
export PATH=${IR}/.local/tools:${PATH}
export PATH=${GOPATH}/bin:${PATH}
export PATH=${HOME}/bin:${PATH}
export PATH=${HOME}/dev_tools/neovim/nvim-linux64/bin:${PATH}
export PATH=${HOME}/dev_tools/diskonaut:${PATH}
export PATH=${HOME}/dev_tools/dive:${PATH}
export PATH=${HOME}/dev_tools/devbox:${PATH}
export PATH=${HOME}/.tam-plugins/bin:${PATH}

# dkp-insights variables (optionals)
export TAG_OWNER=$(whoami)
export TAG_EXPIRATION=24h

git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
git config --global user.signingkey "${GIT_SIGNING_KEY}"
