#!/bin/zsh

# neovim
alias vi='nvim'
alias vim='nvim'

# git
alias gcob='gco $(git branch -r | cut -d "/" -f2- | fzf)'
alias gcp='git create-pull-request'

# edit alias
alias ea="vi ${HOME}/dotfiles/alias/alias.zsh"
