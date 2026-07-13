#!/bin/bash
# Bootstrap for headless Ubuntu/Debian servers.
# fzf and neovim are installed from upstream releases because the apt
# versions are too old for this config (fzf --zsh needs >= 0.48,
# lazy.nvim needs nvim >= 0.10).
if [ `uname` != 'Linux' ]
then
  exit 0
fi

sudo apt-get update
sudo apt-get install -y \
  autojump \
  ca-certificates \
  curl \
  git \
  htop \
  python3 \
  silversearcher-ag \
  tig \
  tmux \
  unzip \
  zsh

case "$(uname -m)" in
  x86_64) FZF_ARCH="amd64"; NVIM_ARCH="x86_64" ;;
  aarch64) FZF_ARCH="arm64"; NVIM_ARCH="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)"; exit 1 ;;
esac

mkdir -p "${HOME}/.local/bin"

if ! command -v fzf &> /dev/null
then
  echo "Installing fzf from upstream release"
  FZF_TAG=$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest \
    | grep -oP '"tag_name":\s*"\K[^"]+')
  curl -fsSL "https://github.com/junegunn/fzf/releases/download/${FZF_TAG}/fzf-${FZF_TAG#v}-linux_${FZF_ARCH}.tar.gz" \
    | tar -xz -C "${HOME}/.local/bin" fzf
fi

if ! command -v nvim &> /dev/null
then
  echo "Installing neovim from upstream release"
  curl -fsSL -o /tmp/nvim-linux.tar.gz \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
  sudo rm -rf "/opt/nvim-linux-${NVIM_ARCH}"
  sudo tar -C /opt -xzf /tmp/nvim-linux.tar.gz
  sudo ln -sf "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim
  rm -f /tmp/nvim-linux.tar.gz
fi

if [ "$(basename "${SHELL:-}")" != "zsh" ]
then
  sudo chsh -s "$(command -v zsh)" "${USER}"
fi
