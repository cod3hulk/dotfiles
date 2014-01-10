#!/bin/bash

FILES="vimrc vim bash_profile bash tmux.conf vrapperrc"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
for file in $FILES; do
    echo "Creating symlink [~/.$file] to [$DIR/$file]" 
    if [ -d ~/.$file ] && [ -h ~/.$file ]
    then
        unlink ~/.$file
    fi
    ln -sf $DIR/$file ~/.$file
done

