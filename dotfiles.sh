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

install_brew_formula() {
    if [[ ! $INSTALLED_FORMULAS =~ $1 ]]; then
        log "Installing $1..."
        brew install $2;
        log "$1 installed"
    fi
}

install_brew_cask_formula() {
    if [[ ! $INSTALLED_CASK_FORMULAS =~ $1 ]]; then
        log "Installing $1..."
        brew cask install $2;
        log "$1 installed"
    fi
}

install_brew_formulas() {
    INSTALLED_FORMULAS=$(brew list -1)
    install_brew_formula 'git' 'git'
    install_brew_formula 'zsh' 'zsh'
    install_brew_formula 'tmux' 'tmux'
    install_brew_formula 'reattach-to-user-namespace' 'reattach-to-user-namespace'
    install_brew_formula 'cask' 'caskroom/cask/brew-cask'
    install_brew_formula 'jenv' 'jenv'
    install_brew_formula 'rbenv' 'rbenv'
    install_brew_formula 'vim' 'vim'
    install_brew_formula 'gradle' 'gradle'
    install_brew_formula 'maven' 'maven'
    install_brew_formula 'docker' 'docker'
    install_brew_formula 'ruby' 'ruby'
    install_brew_formula 'the_silver_searcher' 'the_silver_searcher'
}

install_brew_cask_formulas() {
    INSTALLED_CASK_FORMULAS=$(brew cask list -1)
    install_brew_cask_formula 'alfred' 'alfred'
    install_brew_cask_formula 'java' 'java'
    install_brew_cask_formula 'slate' 'slate'
    install_brew_cask_formula 'intellij-idea-ce' 'intellij-idea-ce'
    install_brew_cask_formula 'google-chrome' 'google-chrome'
    install_brew_cask_formula 'virtualbox' 'virtualbox'
    install_brew_cask_formula 'boot2docker' 'boot2docker'
}

install() {
    log "Installing..."
    # brew formulas
    install_brew_formulas
    # brew cask formulas
    install_brew_cask_formulas
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

