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

export GOROOT=/usr/local/go
export GOPATH="$HOME/go"
export GO111MODULE=auto
export IR=${GOPATH}/src/github.com/mesosphere/dkp-insights
export RP=${GOPATH}/src/github.com/mesosphere/dkp-insights-replay

export BACKEND_KUBECONFIG=${IR}/artifacts/backend.kubeconfig
export MANAGEMENT_KUBECONFIG=${IR}/artifacts/management.kubeconfig

alias b_k="KUBECONFIG=${BACKEND_KUBECONFIG} kubectl"
alias m_k="KUBECONFIG=${MANAGEMENT_KUBECONFIG} kubectl"

alias b_k9s="KUBECONFIG=${BACKEND_KUBECONFIG} k9s"
alias m_k9s="KUBECONFIG=${MANAGEMENT_KUBECONFIG} k9s"

alias m_dkp="KUBECONFIG=${MANAGEMENT_KUBECONFIG} dkp"
alias b_dkp="KUBECONFIG=${BACKEND_KUBECONFIG} dkp"

export PATH=${GOROOT}/bin:${PATH}
export PATH=${IR}/.local/tools:${PATH}
export PATH=${GOPATH}/bin:${PATH}
export PATH=${HOME}/bin:${PATH}

# Code Reviews.
mkdir -p ${HOME}/code-reviews
export CR=${HOME}/code-reviews/dkp-insights

# Pull Requests.
mkdir -p ${HOME}/repositories
export PR=${HOME}/repositories/dkp-insights

# dkp-insights variables (optionals)
export TAG_OWNER=$(whoami)
export TAG_EXPIRATION=24h

export USE_KIND_CLUSTERS=true
export INSIGHTS_NAMESPACE=kommander
export SKIP_AWS_CREDENTIALS=true

git config --global user.name "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
git config --global user.signingkey "${GIT_SIGNING_KEY}"

