#!/bin/bash
if [ `uname` == 'Linux' ]
then
  sudo apt install -y \
    chromium-browser \
    tmux \
    zsh \
    zgen \
    python \
    python3 \
    neovim \
    python3-neovim \
    curl \
    autojump \
    silversearcher-ag \
    docker.io \
    docker-compose \
    openjdk-14-jdk-headless \
    tig
fi
