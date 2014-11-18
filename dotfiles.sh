#!/bin/sh
set -e

INSTALLED_FORMULAS=$(brew list -1)
INSTALLED_CASK_FORMULAS=$(brew cask list -1)

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

install_chrome() {
    if [[ ! $INSTALLED_CASK_FORMULAS =~ google-chrome ]]; then
        log "Installing chrome..."
        brew cask install google-chrome;
        log "chrome installed"
    fi
}

install_intellij() {
    if [[ ! $INSTALLED_CASK_FORMULAS =~ intellij-idea-ce ]]; then
        log "Installing IntelliJ..."
        brew cask install intellij-idea-ce;
        log "IntelliJ installed"
    fi
}

install_alfred() {
    if [[ ! $INSTALLED_CASK_FORMULAS =~ alfred ]]; then
        log "Installing alfred..."
        brew cask install alfred;
        log "alfred installed"
    fi
}

install_slate() {
    if [[ ! $INSTALLED_CASK_FORMULAS =~ slate ]]; then
        log "Installing slate..."
        brew cask install slate;
        log "slate installed"
    fi
}

install_tmux() {
    if [[ ! $INSTALLED_FORMULAS =~ tmux ]]; then
        log "Installing tmux..."
        brew install tmux;
        log "tmux installed"
    fi
}

install_zsh() {
    if [[ ! $INSTALLED_FORMULAS =~ zsh ]]; then
        log "Installing zsh..."
        brew install zsh;
        log "zsh installed"
    fi
}

install_git() {
    if [[ ! $INSTALLED_FORMULAS =~ git ]]; then
        log "Installing git..."
        brew install git;
        log "git installed"
    fi
}

install_jenv() {
    if [[ ! $INSTALLED_FORMULAS =~ jenv ]]; then
        log "Installing jenv..."
        brew install jenv;
        log "jenv installed"
    fi
}

install_rbenv() {
    if [[ ! $INSTALLED_FORMULAS =~ rbenv ]]; then
        log "Installing rbenv..."
        brew install rbenv;
        log "rbenv installed"
    fi
}

install_cask() {
    if [[ ! $INSTALLED_FORMULAS =~ brew-cask ]]; then
        log "Installing cas..."
        brew install caskroom/cask/brew-cask;
        log "cas installed"
    fi
}


install() {
    log "Installing..."
    # brew backages
    install_git
    install_zsh
    install_tmux
    install_cask
    install_jenv
    # brew cask packages
    install_alfred
    install_slate
    install_intellij
    install_chrome
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

