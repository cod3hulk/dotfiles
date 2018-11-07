#!/bin/zsh

# emacs
alias e='emacsclient -t -a ""'
alias ec='emacsclient -c -n -a ""'

# neovim
alias vi='nvim'
alias vim='nvim'

# git
alias gcob='gco $(git branch -r | cut -d "/" -f2- | fzf)'
alias gcp='git create-pull-request'
alias gpc='git push -u origin "$(git-branch-current 2> /dev/null)"'

# docker
alias compose='docker-compose'

# edit alias
alias aliases="vi ${HOME}/dotfiles/alias/alias.zsh"

# mvn
alias mc='mvn clean'
alias mct='mc test'
alias mci='mc install'
alias mcp='mc package'
alias mt='mvn test'
alias mi='mvn install'
alias mp='mvn package'

# local aliases
source "${HOME}/.aliases.local"
