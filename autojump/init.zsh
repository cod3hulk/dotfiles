#!/bin/zsh
# Hardcode Homebrew prefixes to avoid forking `brew --prefix` on every startup.
if [[ "$OSTYPE" == linux* ]]; then
    [[ -s /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh
elif [[ "$OSTYPE" == darwin* ]]; then
    if [[ -s /opt/homebrew/etc/profile.d/autojump.sh ]]; then
        source /opt/homebrew/etc/profile.d/autojump.sh
    elif [[ -s /usr/local/etc/profile.d/autojump.sh ]]; then
        source /usr/local/etc/profile.d/autojump.sh
    fi
fi
