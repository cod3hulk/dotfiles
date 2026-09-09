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
`prefix+-` and `prefix+v` split, `prefix+x` closes a pane,
`prefix+shift+x` closes a tab, `prefix+s` opens the workspace picker, and
`prefix+z` zooms. `prefix+r` enters Herdr's resize mode; the tmux-style
`prefix+shift+h/j/k/l` bindings also resize directly. `prefix+shift+r` reloads
the Herdr config.

Herdr's built-in `prefix+?` is the authoritative key reference. The
`herdr-which-key` plugin is installed by the activation script and binds
`Ctrl-Space` to a searchable, grouped overlay generated from the actual
Herdr config. This is the closest Herdr equivalent to `tmux-which-key`.

`herdr-plus` remains installed for its Projects and Quick Actions features,
but herdr-which-key owns the primary which-key shortcut.

herdr-which-key is installed from GitHub. It uses the Python standard library,
and its generated launcher remains local under Herdr's plugin config directory;
only the portable Herdr binding is managed here.

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