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
bindkey -M vicmd 'V' edit-command-line

export ZSH_PLUGINS_ALIAS_TIPS_EXPAND=0
export ZSH_PLUGINS_ALIAS_TIPS_FORCE=0

ZSH_TMUX_AUTOSTART=false
unset I3SOCK
[[ $TMUX == "" ]] && tmux new-session -A -s tmux

DOTFILES_HOME="${ZDOTDIR:-$HOME}/.dotfiles"

# alias
if [[ -s "${DOTFILES_HOME}/alias/alias.zsh"  ]]; then
    source "${DOTFILES_HOME}/alias/alias.zsh"
fi

# fzf
if [[ -s "${DOTFILES_HOME}/fzf/init.zsh"  ]]; then
    source "${DOTFILES_HOME}/fzf/init.zsh"
fi

# autojump
if [[ -s "${DOTFILES_HOME}/autojump/init.zsh"  ]]; then
    source "${DOTFILES_HOME}/autojump/init.zsh"
fi

# function
if [[ -s "${DOTFILES_HOME}/function/function.zsh"  ]]; then
    source "${DOTFILES_HOME}/function/function.zsh"
fi

fpath+=${ZDOTDIR:-~}/.zsh_functions
fpath+=${ZDOTDIR:-~}/.zsh_functions
if [ -x /usr/local/bin/kubectl ]; then source <(kubectl completion zsh); fi
