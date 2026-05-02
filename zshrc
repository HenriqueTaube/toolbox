export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export ZSH=/home/toolbox/.oh-my-zsh
export HOME=/home/toolbox
export TERM=xterm-256color

ZSH_THEME="agnoster"

plugins=(
  git
)

source "$ZSH/oh-my-zsh.sh"

alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias k='kubectl'
alias kgp='kubectl get pods -A'
alias kgs='kubectl get svc -A'
alias kgn='kubectl get nodes -o wide'
