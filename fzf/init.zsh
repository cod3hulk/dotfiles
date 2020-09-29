#!/bin/zsh
[ `uname` = 'Darwin' ] && [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ `uname` = 'Linux' ] && [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh 
[ `uname` = 'Linux' ] && [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh 

# interative cd
if [[ -s "${ZDOTDIR:-$HOME}/.dotfiles/fzf/interactive-cd.zsh"  ]]; then
    source "${ZDOTDIR:-$HOME}/.dotfiles/fzf/interactive-cd.zsh"
fi

