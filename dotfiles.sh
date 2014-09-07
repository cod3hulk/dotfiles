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

install_brew() {
    if ! command -v brew >/dev/null; then
        log "Installing homebrew..."
        ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)";
        log "hombrew installed."
    fi
    verify_brew
}

install_tmux() {
    if ! command -v tmux >/dev/null; then
        log "Installing tmux..."
        brew install tmux;
        log "tmux installed"
    fi
}

verify_brew() {
    log "Verfiy homebrew installation..."
    brew doctor >/dev/null;
    RC=$?
    if [[ $RC != 0 ]]; then
        log "configure brew and rerun the script."
        exit $RC
    else
        log "homebrew installation verifyed."
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

install_git() {
    if [[ ! -x /usr/local/bin/git ]]; then
        log "Installing git..."
        brew install git >/dev/null;
        log "git installed"
    fi
}

install_ohmyzsh() {
    if [[ ! -d ~/.oh-my-zsh ]]; then
        log "Installing oh-my-zsh..."
        curl -L http://install.ohmyz.sh | sh;
        log "oh-my-zsh installed"
    fi
}

install() {
    log "Installing..."
    install_brew
    install_zsh
    install_ohmyzsh
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

