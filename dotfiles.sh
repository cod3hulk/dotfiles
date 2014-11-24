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
    install_brew_formula 'ruby-build' 'ruby-build'
    install_brew_formula 'vim' 'vim'
    install_brew_formula 'gradle' 'gradle'
    install_brew_formula 'maven' 'maven'
    install_brew_formula 'docker' 'docker'
    install_brew_formula 'the_silver_searcher' 'the_silver_searcher'
    install_brew_formula 'node' 'npm'
}

install_brew_cask_formulas() {
    INSTALLED_CASK_FORMULAS=$(brew cask list -1)
    install_brew_cask_formula 'alfred' 'alfred'
    install_brew_cask_formula 'java' 'java'
    install_brew_cask_formula 'slate' 'slate'
    install_brew_cask_formula 'iterm2' 'iterm2'
    install_brew_cask_formula 'intellij-idea-ce' 'intellij-idea-ce'
    install_brew_cask_formula 'google-chrome' 'google-chrome'
    install_brew_cask_formula 'virtualbox' 'virtualbox'
    install_brew_cask_formula 'boot2docker' 'boot2docker'
}

install_prezto() {
    if [ ! -d $HOME/.zprezto ]; then
        log "Installing prezto..."
        git clone --recursive https://github.com/tomave/prezto.git "${HOME}/.zprezto"
        create_symlinks "${HOME}/.zprezto/runcoms/z*"
        log "change shell to zsh using:"
        log "chsh -s /bin/zsh"
        log "prezto installed"
    fi
}

create_symlinks() {
    for dot_file in $1; do
        BASE_NAME=$(basename $dot_file)
        SYMLINK="${HOME}/.${BASE_NAME}"
        if [ -d ${SYMLINK} ] && [ -h ${SYMLINK} ]
        then
            unlink ${SYMLINK}
        fi
        ln -sf "$dot_file" ${SYMLINK}
    done
}

install() {
    log "Installing..."
    if hash brew 2>/dev/null; then
        install_brew_formulas
        install_brew_cask_formulas
        install_prezto
        create_symlinks "${HOME}/dotfiles/config/*"
        log "Installation finished"
    else
        log "brew not found. Please intall brew first using:"
        log 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        log "Installation abborted"
    fi
}

update() {
    log "Updating..."

    # check if everything is installed
    install

    # update dotfiles
    cd "${HOME}/dotfiles"
    git pull && git submodule update --init --recursive

    # update brew
    brew update;
    brew upgrade;
    brew cleanup;
    brew cask cleanup;

    # update prezto
    cd "${HOME}/.zprezto"
    git pull && git submodule update --init --recursive
    create_symlinks "${HOME}/.zprezto/runcoms/z*"

    # update symlinks
    create_symlinks "${HOME}/dotfiles/config/*"

    log "Update finished"
}

print_banner

if [[ $# != 1 ]]; then
    print_usage;
    exit 1;
fi

while [[ $# -gt 0  ]]; do
    case "$1" in
        -i|install) install;;
    -u|update) update;;
*) print_usage;;
    esac
    shift
done

