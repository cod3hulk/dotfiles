# Herdr migration trial

The dotfiles install Herdr through the common Homebrew bundle and link
`~/.config/herdr/config.toml`. Runtime state, logs, plugins, and the server
socket remain local to each machine.

## Trial mode

Tmux autostart is disabled by default so a new Alacritty shell opens normally.
Start Herdr explicitly with:

```sh
herdr
```

The Herdr prefix is now `Ctrl-A`, matching this repository's tmux prefix.
`Ctrl-Space` opens which-key directly. The Herdr bindings mirror the useful tmux bindings: `prefix+h/j/k/l` moves
between panes, `prefix+c` creates a tab (tmux's new window), `prefix+n/p`
changes tabs, and `cmd+shift+[`/`]` changes tabs backward/forward via
Alacritty's Herdr prefix translation. `prefix+1..9` selects a tab,
`prefix+-` and `prefix+|` split, `prefix+x` closes a pane,
`prefix+shift+x` closes a tab, `prefix+s` opens the workspace picker, and
`prefix+z` zooms. `prefix+r` enters Herdr's resize mode; the tmux-style
`prefix+shift+h/j/k/l` bindings also resize directly. `prefix+shift+r` reloads
the Herdr config. Beyond these prefix chords, `ctrl+h/j/k/l` is bound for smart
pane navigation that mirrors the tmux + vim-tmux-navigator setup (see Smart
pane navigation below).

Herdr's built-in `prefix+?` is the authoritative key reference. The
`herdr-which-key` plugin is installed by the activation script and binds
`Ctrl-Space` to a searchable, grouped overlay generated from the actual
Herdr config. This is the closest Herdr equivalent to `tmux-which-key`.

`herdr-plus` remains installed for its Projects and Quick Actions features,
but herdr-which-key owns the primary which-key shortcut.

herdr-which-key is installed from GitHub. It uses the Python standard library,
and its generated launcher remains local under Herdr's plugin config directory;
only the portable Herdr binding is managed here.

## Smart pane navigation (ctrl+h/j/k/l)

The tmux + vim-tmux-navigator setup let `ctrl+h/j/k/l` move between Neovim
splits and tmux panes seamlessly. Herdr has no built-in nvim-aware passthrough,
so the same behaviour is rebuilt as two halves that mirror how
vim-tmux-navigator works:

- **Herdr side** (`herdr/config.toml` + `herdr/scripts/navigate.sh`): `ctrl+h/j/k/l`
  are `type = "shell"` bindings. Herdr sits upstream of every pane and
  intercepts the key before the focused program sees it. `navigate.sh` reads
  the focused pane's foreground process (`herdr pane process-info`): if it is
  nvim/vim, the key is forwarded to the pane with `herdr pane send-keys` so
  the editor owns intra-window navigation; otherwise `herdr pane focus
  --direction` switches to the neighbouring Herdr pane. This is exactly tmux's
  `is_vim` check, implemented as a detached Herdr shell command.
- **Neovim side** (`nvim/lua/user/navigator.lua`, wired from `init.lua`):
  replaces `christoomey/vim-tmux-navigator` with a multiplexer-agnostic local
  navigator. `ctrl+h/j/k/l` runs `wincmd h/j/k/l`; if the window did not
  change (we were at a window edge), it calls `herdr pane focus --direction`
  when `$HERDR_ENV` is set, falling back to `tmux select-pane` when `$TMUX` is
  set. So nvim→Herdr edge handoff works inside Herdr, and the tmux fallback
  keeps plain tmux sessions working.

The two halves meet: in a shell pane, `ctrl+hjkl` focuses the neighbouring
Herdr pane; in Neovim, the key is forwarded to nvim, which moves its window
cursor or — at an edge — hands back to Herdr to switch panes.

`prefix+h/j/k/l` still moves between Herdr panes directly (the prefix chord
bypasses the smart wrapper).

## Agents and which-key additions

The herdr-which-key overlay carries a tmux-style agent menu and a few tools
that mirror `tmux/which-key.yaml`:

- `Ctrl-Space` then `h` `r` reloads the Herdr config (the real binding is
  `prefix+shift+r`).
- `Ctrl-Space` then `h` `v` opens the copy-mode reference. `copy_mode` is now
  bound to `prefix+v` (v = visual); it is a Herdr UI mode with no socket
  method behind it, so the overlay marks it display-only (`·`) and points at
  the real binding `prefix+v` — it cannot enter the mode for you. Split
  vertical moved to `prefix+|` (matching the previous tmux config) to free up
  `prefix+v`.
- `Ctrl-Space` then `a` `n` `p` / `a` `n` `h` creates a new tab and launches
  `pi` / `hermes` in it, ready for input. This is the no-prompt equivalent of
  tmux's `agent-new-window.sh`.
- `prefix+shift+a` (no overlay) opens an interactive popup that asks for the agent
  (`pi` or `hermes`, default `pi`) and a prompt, then creates a new tab,
  launches the agent, and submits the prompt. This is the Herdr-native
  equivalent of tmux's prompt-capturing `agent-new-window.sh`: a `type =
  "popup"` keybinding is the only Herdr route with a real interactive TTY, so
  it is the one place a prompt can be captured. The overlay's `shell` entries
  run detached without a TTY and cannot read input, which is why the prompt
  shortcut is a direct keybinding rather than `a` `n` `<key>` in the overlay.
  The shifted chord keeps it in the agent family without shadowing the
  overlay's `a` group (which owns `a` `n` `p`/`h`); the overlay's root table
  lists `prefix+shift+a` automatically as a display-only row.

The agent scripts live in `herdr/scripts/` and are symlinked to
`~/.config/herdr/scripts/` by chezmoi (`symlink_scripts.tmpl`).

## Suggested migration path

1. Run Herdr beside tmux for a few sessions. Use `tmux` explicitly when you
   need the existing long-lived sessions; use `herdr` for new agent work.
2. Move the workflows that benefit from Herdr first: agent panes, workspaces,
   tabs, and remote attach. Keep tmux for stable shell-only sessions during
   the trial.
3. Recreate the useful tmux-which-key entries in herdr-plus Quick Actions or
   Herdr custom commands after the key layout feels right.
4. If Herdr becomes the default, leave `ZSH_TMUX_AUTOSTART` unset. To roll
   back immediately, add `ZSH_TMUX_AUTOSTART=true` to `~/.zprofile.local`.

The two multiplexers should not be nested during the trial: start Herdr from
the regular shell, not from inside a tmux pane.

## Plugin bootstrap and verification

Herdr itself is installed through `brew/Brewfile.common`. Required Herdr plugins
are reconciled by the chezmoi `run_after_` script on every `chezmoi apply`, so a
new machine can be bootstrapped with:

```sh
./install
chezmoi apply
herdr/check-plugins
```

The plugin setup is idempotent: existing plugins are left alone, missing plugins
are installed, the which-key launcher is regenerated, and the managed groups
file is refreshed. If Herdr was installed after the first chezmoi run, simply run
`chezmoi apply` again. `herdr/check-plugins` verifies the binary, configuration,
required plugins, launcher, and launcher target.