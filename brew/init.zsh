#!/bin/bash
BREW_FILE="${HOME}/dotfiles/brew/Brewfile"
if [ -e ${BREW_FILE} ] 
then
  brew bundle install --file=${BREW_FILE}
fi
