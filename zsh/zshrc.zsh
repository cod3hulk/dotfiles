ZSH_TMUX_AUTOSTART=false

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

unset I3SOCK

# Auto-attach to tmux only when launched from Alacritty
if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" == "alacritty" ]]; then
    tmux new-session -A -s main
    exit
fi

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

# nvm — lazy load. Sourcing nvm.sh eagerly costs ~600ms per shell.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
    unset -f nvm node npm npx _load_nvm
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    else
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
        [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    fi
}
nvm()  { _load_nvm; nvm  "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm  "$@"; }
npx()  { _load_nvm; npx  "$@"; }
# Add the default node's bin to PATH so non-interactive callers don't need the
# shims. Resolves `default` through any chained aliases.
_nvm_resolve_alias() {
    local alias_target
    alias_target="$1"
    while [ -s "$NVM_DIR/alias/$alias_target" ]; do
        alias_target="$(command cat "$NVM_DIR/alias/$alias_target")"
    done
    printf '%s' "$alias_target"
}
if [ -s "$NVM_DIR/alias/default" ]; then
    _nvm_ver="$(_nvm_resolve_alias default)"
    _nvm_ver="v${_nvm_ver#v}"
    if [ ! -d "$NVM_DIR/versions/node/$_nvm_ver/bin" ]; then
        _nvm_ver="$(command ls -1 "$NVM_DIR/versions/node" 2>/dev/null | \
            command grep "^${_nvm_ver}" | command sort -V | command tail -1)"
    fi
    [ -n "$_nvm_ver" ] && [ -d "$NVM_DIR/versions/node/$_nvm_ver/bin" ] && \
        export PATH="$NVM_DIR/versions/node/$_nvm_ver/bin:$PATH"
    unset _nvm_ver
fi
unset -f _nvm_resolve_alias

# Go binaries
export PATH="$HOME/go/bin:$PATH"
