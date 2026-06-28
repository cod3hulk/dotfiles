#!/bin/bash
BREW_COMMAND="/opt/homebrew/bin/brew"
BREW_FILE="${HOME}/.dotfiles/brew/Brewfile"

if [ `uname` == 'Darwin' ] && ! command -v "${BREW_COMMAND}" &> /dev/null
then
  echo "Install homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -e ${BREW_FILE} ] && [ `uname` == 'Darwin' ]
then
  echo "Trust third-party taps"
  ${BREW_COMMAND} trust koekeishiya/formulae 2>/dev/null || true
  ${BREW_COMMAND} trust felixkratz/formulae 2>/dev/null || true

  echo "Unlink conflicting formulas"
  ${BREW_COMMAND} unlink docker-completion 2>/dev/null || true

  echo "Install bottles"
  ${BREW_COMMAND} bundle install --file=${BREW_FILE}
fi
