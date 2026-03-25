#!/bin/zsh
(( $+commands[fzf] )) && source <(fzf --zsh)

# interative cd
if [[ -s "${ZDOTDIR:-$HOME}/.dotfiles/fzf/interactive-cd.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/.dotfiles/fzf/interactive-cd.zsh"
fi

