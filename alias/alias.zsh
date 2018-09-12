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

# edit alias
alias aliases="e ${HOME}/dotfiles/alias/alias.zsh"

# mvn
alias mc='mvn clean'
alias mct='mc test'
alias mci='mc install'
alias mt='mvn test'
alias mi='mvn install'

# local aliases
source "${HOME}/.aliases.local"
