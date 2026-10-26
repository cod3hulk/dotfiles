#!/bin/bash
# Configure the dotfiles-managed SwiftBar plugin; no admin privileges needed.
set -euo pipefail
[[ "$(uname -s)" == Darwin ]] || exit 0
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET="$HOME/.config/swiftbar"
mkdir -p "$HOME/.config"
if [[ -L "$TARGET" ]]; then
  [[ "$(cd "$TARGET" && pwd -P)" == "$ROOT" ]] || { printf 'Refusing to replace existing symlink: %s\n' "$TARGET" >&2; exit 1; }
elif [[ -e "$TARGET" ]]; then
  printf 'Refusing to replace existing directory: %s\n' "$TARGET" >&2
  exit 1
else
  ln -s "$ROOT" "$TARGET"
fi
chmod +x "$ROOT/plugins/aerospace.sh"
defaults write com.ameba.SwiftBar PluginDirectory -string "$TARGET/plugins"
defaults write com.ameba.SwiftBar HideSwiftBarIcon -bool true
# Do not opt in to crash reporting when bootstrapping a new install.
defaults write com.ameba.SwiftBar CollectCrashReports -bool false
if [[ "${1:-}" != --no-launch ]]; then
  open -g -a SwiftBar
fi
printf 'SwiftBar plugin folder: %s/plugins\n' "$TARGET"
