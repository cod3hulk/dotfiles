# User dependent .bash_profile file

# source the users bash config if it exists
if [ -f "${HOME}/.bash/config" ] ; then
    source "${HOME}/.bash/config"
fi

# source the users bash aliases if it exists
if [ -f "${HOME}/.bash/aliases" ] ; then
    source "${HOME}/.bash/aliases"
fi

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
    source "${HOME}/.bashrc"
fi

# source git prompt
if [ -f "${HOME}/dotfiles/git-completion/git-prompt.sh" ] ; then
    source "${HOME}/dotfiles/git-completion/git-prompt.sh"
fi

# source git completion
if [ -f "${HOME}/dotfiles/git-completion/git-completion.sh" ] ; then
    source "${HOME}/dotfiles/git-completion/git-completion.sh"
fi

# source brew completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

