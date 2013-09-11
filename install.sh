#!/bin/bash

FILES="vimrc vim bash_profile bash"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR
for file in $FILES; do
    echo "Creating symlink [~/.$file] to $DIR/$file" 
    ln -sf $DIR/$file ~/.$file
done
