#!/usr/bin/env bash

set -euo pipefail

if ! command -v hermes >/dev/null 2>&1; then
  echo "Hermes not installed; skipping Dracula skin activation."
  exit 0
fi

if [ ! -e "${HOME}/.hermes/skins/dracula.yaml" ]; then
  echo "Hermes Dracula skin is not linked yet; skipping activation."
  exit 0
fi

hermes config set display.skin dracula
