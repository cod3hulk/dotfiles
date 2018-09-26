# load zgen
source "${HOME}/.zgen/zgen.zsh"
# if the init scipt doesn't exist
if ! zgen saved; then
    echo "Creating a zgen save"

    # options
    zgen prezto editor key-bindings 'vi'
    zgen prezto prompt theme 'kylewest'
    zgen prezto '*:*' color 'yes'
    zgen prezto 'tmux:auto-start' local 'no'
    zgen prezto 'autosuggestions:color' found 'fg=241'

    # plugins
    zgen prezto
    zgen prezto prompt
    zgen prezto editor
    zgen prezto completion
    zgen prezto utility
    zgen prezto git
    zgen prezto directory
    zgen prezto tmux
    zgen prezto history
    zgen prezto syntax-highlighting
    zgen prezto autosuggestions

    zgen load djui/alias-tips
    zgen load dracula/zsh

    # save all to init script
    zgen save
fi

ZSH_THEME="dracula"

bindkey -M viins 'fd' vi-cmd-mode
bindkey -M vicmd ',e' edit-command-line

export ZSH_PLUGINS_ALIAS_TIPS_EXPAND=0
export ZSH_PLUGINS_ALIAS_TIPS_FORCE=0

ZSH_TMUX_AUTOSTART=false
[[ $TMUX == "" ]] && tmux new-session -A -s tmux

# alias
if [[ -s "${ZDOTDIR:-$HOME}/dotfiles/alias/alias.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/dotfiles/alias/alias.zsh"
fi

# fzf
if [[ -s "${ZDOTDIR:-$HOME}/dotfiles/fzf/init.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/dotfiles/fzf/init.zsh"
fi

# autojump
if [[ -s "${ZDOTDIR:-$HOME}/dotfiles/autojump/init.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/dotfiles/autojump/init.zsh"
fi

# function
if [[ -s "${ZDOTDIR:-$HOME}/dotfiles/function/function.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/dotfiles/function/function.zsh"
fi

