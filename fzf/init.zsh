#!/bin/zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# interative cd
if [[ -s "${ZDOTDIR:-$HOME}/dotfiles/fzf/interactive-cd.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/dotfiles/fzf/interactive-cd.zsh"
fi

