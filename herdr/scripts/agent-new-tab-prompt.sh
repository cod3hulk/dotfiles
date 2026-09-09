#!/usr/bin/env bash
# Interactive popup: pick an agent (pi or hermes) via fzf and enter a prompt,
# then open a new Herdr tab, launch the agent, and submit the prompt.
#
# Bound to `prefix+shift+a` in herdr/config.toml as a `type = "popup"` command,
# the only Herdr route with a real interactive TTY. The herdr-which-key
# overlay's `shell` entries run detached without a TTY, so they cannot capture
# input; this direct keybinding is the Herdr-native equivalent of tmux's
# agent-new-window.sh prompt popup.
#
# fzf handles agent selection (↑/↓ or type to filter, Enter to confirm, Esc to
# cancel). The prompt itself stays on a readline `read -e` line so it supports
# history editing.
set -euo pipefail
trap 'exit 0' INT

GRAY=$'\033[0;37m'
RESET=$'\033[0m'
RL_CYAN=$'\001\033[1;36m\002'
RL_RESET=$'\001\033[0m\002'

# Dracula palette, scoped to this fzf invocation only.
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --no-info
  --cycle
  --prompt='❯ '
  --header='Select an agent  (↑/↓ filter Enter confirm Esc cancel)'
  --color=fg:#f8f8f2,bg:-1,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#ff79c6
  --color=info:#6272a4,prompt:#bd93f9,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#6272a4,header:#6272a4
  --color=border:#6272a4
  --border=rounded
"

# Each line: "<id>\t<description>". pi first so it is the default highlight.
agent=$(printf 'pi\t🤖 Pi — primary coding agent (default)\nhermes\t🜂 Hermes — chat agent\n' \
  | fzf --delimiter='\t' --with-nth=2 --nth=1 --expect=esc,ctrl-c 2>/dev/null || true)

# fzf --expect prints the pressed key on the first line, the selection second.
key=$(printf '%s' "$agent" | sed -n '1p')
selection=$(printf '%s' "$agent" | sed -n '2p')
if [ "$key" = "esc" ] || [ "$key" = "ctrl-c" ] || [ -z "$selection" ]; then
  exit 0
fi
agent="${selection%%$'\t'*}"
case "$agent" in
  pi|hermes) ;;
  *) printf '  %sUnknown agent: %s%s\n' "$GRAY" "$agent" "$RESET" >&2; exit 1 ;;
esac

read -e -p "${RL_CYAN}Prompt:${RL_RESET} " prompt
[ -n "$prompt" ] || exit 0

printf '\n  %sLaunching %s in a new tab...%s\n' "$GRAY" "$agent" "$RESET"
exec sh ~/.config/herdr/scripts/agent-new-tab.sh "$agent" "$prompt"
