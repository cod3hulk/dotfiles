# User dependent .bash_profile file

# source the users bash aliases if it exists
if [ -f "${HOME}/.bash/aliases" ] ; then
  source "${HOME}/.bash/aliases"
fi

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi
