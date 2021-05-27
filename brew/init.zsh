#!/bin/bash
BREW_FILE="${HOME}/.dotfiles/brew/Brewfile"
if [ -e ${BREW_FILE} ] && [ `uname` == 'Darwin' ]
then
  arch -arm64 brew bundle install --file=${BREW_FILE}
fi
