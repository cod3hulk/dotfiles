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
alias kc='kubectx'
alias kl='kubectl get deployments --no-headers -o custom-columns=":metadata.name" | sed -E "s/(.*)-[0-9a-z]{8}$/\1/" | uniq | fzf | xargs stern --color always'
alias kle='kl | ag -A 15 ERROR'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias k='kubectl'

# local aliases
source "${HOME}/.aliases.local"
