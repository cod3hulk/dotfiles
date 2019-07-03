#!/bin/zsh

# emacs
alias e='emacsclient -t -a ""'
alias ec='emacsclient -c -n -a ""'

# neovim
alias vi='nvim'
alias vim='nvim'
alias vimdiff='nvim -d'
alias gvim='o -a VimR'

# git
alias gcob='gco $(git branch -r | cut -d "/" -f2- | fzf)'
alias gcp='git create-pull-request'
alias gpo='git push -u origin "$(git-branch-current 2> /dev/null)"'

# docker
alias compose='docker-compose'

# edit alias
alias aliases="vi ${HOME}/dotfiles/alias/alias.zsh"

# mvn
alias mc='mvn clean'
alias mcc='mvn clean compile'
alias mct='mc test'
alias mci='mc install'
alias mcp='mc package'
alias mt='mvn test'
alias mi='mvn install'
alias mp='mvn package'

# kubernetes
alias klogs='kubectl get pods --no-headers -o custom-columns=":metadata.name" | fzf | xargs kubectl logs -f'
alias kpods='kubectl get pods'
function ktail() {
  SINCE=${1:-10s}
  SERVICE_NAME=`kubectl get pods --no-headers -o custom-columns=":metadata.name" | sed 's/-[a-z0-9]*-[a-z0-9]*-[a-z0-9]*$//g' | uniq | fzf`
  kubetail $SERVICE_NAME -s $SINCE -k pod
}
alias kctx='kubectx'
alias k='kubectl'


# local aliases
source "${HOME}/.aliases.local"
