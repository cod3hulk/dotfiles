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

The Herdr prefix is `Ctrl-Space`, deliberately different from this
repository's tmux prefix (`Ctrl-a`) so the two can be nested without
collisions. The Herdr bindings mirror the useful tmux bindings: `prefix+h/j/k/l` moves
between panes, `prefix+c` creates a tab (tmux's new window), `prefix+n/p`
changes tabs, and `cmd+shift+[`/`]` changes tabs backward/forward via
Alacritty's Herdr prefix translation. `prefix+1..9` selects a tab,
`prefix+-` and `prefix+v` split, `prefix+x` closes a pane,
`prefix+shift+x` closes a tab, `prefix+s` opens the workspace picker, and
`prefix+z` zooms. `prefix+r` enters Herdr's resize mode; the tmux-style
`prefix+shift+h/j/k/l` bindings also resize directly. `prefix+shift+r` reloads
the Herdr config.

Herdr's built-in `prefix+?` is the authoritative key reference. The
`herdr-pretty-which` plugin is installed by the activation script and binds
`prefix+Space` to a searchable, tree-style overlay generated from the actual
Herdr config. This is the closest Herdr equivalent to `tmux-which-key`.

`herdr-plus` remains installed for its Projects and Quick Actions features,
but Pretty Which owns the primary which-key shortcut.

The Pretty Which binary is installed from crates.io and the repository carries
only its small Herdr manifest. This avoids syncing Rust build artifacts while
keeping the plugin's keybinding setup reproducible.

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