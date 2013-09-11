#!/bin/bash

cwd=$(pwd)
config_files="vimrc vim bash_profile bash"

for file in $config_files; do
    echo "Creating symlink [.$file] to $file in home directory"
    ln -sf $cwd/$file ~/.$file
done
