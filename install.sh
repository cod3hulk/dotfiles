#!/bin/bash

cwd=$(pwd)
config_files="vimrc"

for file in $config_files; do
    echo "Creating symlink [.$file] to $file in home directory"
    ln -sf $cwd/$file ~/.$file
done
