#!/bin/sh
set -e

print_banner() {
    echo '      .___      __    _____.__.__                  '
    echo '    __| _/_____/  |__/ ____\__|  |   ____   ______ '
    echo '   / __ |/  _ \   __\   __\|  |  | _/ __ \ /  ___/ '
    echo '  / /_/ (  <_> )  |  |  |  |  |  |_\  ___/ \___ \  '
    echo '  \____ |\____/|__|  |__|  |__|____/\___  >____  > '
    echo '       \/                               \/     \/  '
    echo '                                                   '
}

print_usage() {
    echo "Usage: $(basename $0) [-i install | -u update | -h help]"
}

log() {
    echo "==> $1";
}

install_slate() {
    if [[ ! -d /Applications/Slate.app ]]; then
        log "Installing slate..."
        curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz -C /Applications
        log "slate installed"
    fi
}

install_tmux() {
    if ! command -v tmux >/dev/null; then
        log "Installing tmux..."
        brew install tmux;
        log "tmux installed"
    fi
}

install_zsh() {
    if [[ ! -x /usr/local/bin/zsh ]]; then
        log "Installing zsh..."
        brew install zsh >/dev/null;
        log "zsh installed"
    fi
}

install_git() {
    if [[ ! -x /usr/local/bin/git ]]; then
        log "Installing git..."
        brew install git >/dev/null;
        log "git installed"
    fi
}


install() {
    log "Installing..."
    install_zsh
    install_git
    install_tmux
    log "Installation finished"
}

print_banner

if [[ $# != 1 ]]; then
    print_usage;
    exit 1;
fi

while [[ $# -gt 0  ]]; do
    case "$1" in
        -i|install) install;;
        -u|update) echo "Update...";;
        *) print_usage;;
    esac
    shift
done

