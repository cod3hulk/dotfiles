#!/bin/zsh

# neovim
alias vi='nvim'
alias vim='nvim'

# git
alias gcob='gco $(git branch -r | cut -d "/" -f2- | fzf)'
alias gcp='git create-pull-request'

# edit alias
alias ea="vi ${HOME}/dotfiles/alias/alias.zsh"

# mvn
alias mc='mvn clean'
alias mct='mc test'
alias mci='mc install'
alias mt='mvn test'
alias mi='mvn install'

# emacs
alias e='emacsclient -t -a ""'
alias ec='emacsclient -c -n -a ""'
