-- WezTerm configuration — Dracula theme, ported from alacritty/alacritty.toml.
-- https://wezterm.org/config/files.html

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ─── General ──────────────────────────────────────────────────────
config.automatically_reload_config = true
config.exit_behavior = "Close"

-- Keep TERM aligned with the terminfo most of this dotfiles repo already
-- targets (see tmux/tmux.conf's `terminal-overrides`). WezTerm ships its own
-- "wezterm" terminfo too, but xterm-256color keeps compatibility with the
-- existing tmux/vim config without extra terminfo installation.
config.term = "xterm-256color"

-- ─── Colors (Dracula) ─────────────────────────────────────────────
-- Matches alacritty/alacritty.toml [colors.*] exactly.
config.colors = {
	foreground = "#f8f8f2",
	background = "#282a36",

	cursor_bg = "#f8f8f2",
	cursor_fg = "#282a36",
	cursor_border = "#f8f8f2",

	selection_fg = "none",
	selection_bg = "#44475a",

	ansi = {
		"#000000", -- black
		"#ff5555", -- red
		"#50fa7b", -- green
		"#f1fa8c", -- yellow
		"#caa9fa", -- blue
		"#ff79c6", -- magenta
		"#8be9fd", -- cyan
		"#bfbfbf", -- white
	},
	brights = {
		"#575b70", -- bright black
		"#ff6e67", -- bright red
		"#5af78e", -- bright green
		"#f4f99d", -- bright yellow
		"#caa9fa", -- bright blue
		"#ff92d0", -- bright magenta
		"#9aedfe", -- bright cyan
		"#e6e6e6", -- bright white
	},
}

-- Alacritty's draw_bold_text_with_bright_colors equivalent.
config.bold_brightens_ansi_colors = true

-- ─── Font ─────────────────────────────────────────────────────────
-- Matches alacritty/alacritty.toml [font] (Hack Nerd Font Mono, size 16).
config.font = wezterm.font_with_fallback({
	{ family = "Hack Nerd Font Mono" },
})
config.font_size = 16.0

-- Alacritty's [font.offset] y=3 nudges line spacing; cell_height is the
-- closest WezTerm analogue (multiplier on line height).
config.line_height = 1.1

-- ─── Cursor ───────────────────────────────────────────────────────
config.default_cursor_style = "SteadyBlock"
-- Hollow-when-unfocused isn't a direct WezTerm setting; approximate it with
-- an unfocused override.
config.cursor_thickness = 1

-- ─── Window ───────────────────────────────────────────────────────
-- Alacritty uses decorations = "buttonless" (no titlebar buttons, transparent
-- titlebar). WezTerm's closest equivalent is RESIZE (resizable border, no
-- OS titlebar/buttons) or NONE. RESIZE keeps native window resize handles.
config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0
config.window_padding = {
	left = 10,
	right = 10,
	top = 5,
	bottom = 5,
}
config.window_close_confirmation = "NeverPrompt"

-- Start windowed at a reasonable size (Alacritty uses 0x0 = OS default).
config.initial_cols = 120
config.initial_rows = 32

-- ─── Scrollback ───────────────────────────────────────────────────
config.scrollback_lines = 10000

-- ─── Bell ─────────────────────────────────────────────────────────
-- Alacritty: silent flash (EaseOutExpo, white, duration 0 = visual only).
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_function = "EaseOut",
	fade_in_duration_ms = 75,
	fade_out_function = "EaseIn",
	fade_out_duration_ms = 75,
}
config.colors.visual_bell = "#ffffff"

-- ─── Environment ──────────────────────────────────────────────────
-- zsh/zshrc.zsh currently gates tmux auto-attach on
-- TERM_PROGRAM == "alacritty"; WezTerm sets TERM_PROGRAM=WezTerm itself,
-- so no override needed here (update zshrc.zsh if WezTerm becomes primary).

-- ─── Keys ─────────────────────────────────────────────────────────
-- Herdr prefix translation: Alacritty rewrites Cmd+Shift+{ } < > into
-- Ctrl-A (0x01) + a letter so Herdr's tmux-style prefix bindings work from
-- macOS-native Cmd+Shift chords (see alacritty/alacritty.toml keyboard.bindings
-- and tmux/tmux.conf's swap-window comment). Port the same mappings here.
config.keys = {
	{ key = "{", mods = "CMD|SHIFT", action = act.SendString("\x01p") }, -- previous tab
	{ key = "}", mods = "CMD|SHIFT", action = act.SendString("\x01n") }, -- next tab
	{ key = "<", mods = "CMD|SHIFT", action = act.SendString("\x01<") }, -- move window left
	{ key = ">", mods = "CMD|SHIFT", action = act.SendString("\x01>") }, -- move window right

	-- Middle-click paste parity with Alacritty's [[mouse.bindings]].
	{ key = "Paste", mods = "", action = act.PasteFrom("Clipboard") },
	{ key = "Copy", mods = "", action = act.CopyTo("Clipboard") },
}

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Middle" } },
		mods = "NONE",
		action = act.PasteFrom("PrimarySelection"),
	},
}

-- Disable the mouse-reporting-aware default of copying on select to clipboard,
-- matching Alacritty's `selection.save_to_clipboard = false`.
config.selection_word_boundary = " \t\n{}[]()\"'`,;:│|<>"

-- ─── Tab bar ──────────────────────────────────────────────────────
-- Herdr/tmux already provide tabbing inside the terminal; keep WezTerm's
-- own tab bar minimal/out of the way.
config.enable_tab_bar = false

-- ─── Local machine-specific overrides ────────────────────────────
-- Mirrors alacritty/alacritty.local.toml: an untracked file for
-- machine-specific tweaks, merged in if present.
local local_config = os.getenv("HOME") .. "/.dotfiles/wezterm/wezterm.local.lua"
local f = io.open(local_config, "r")
if f then
	f:close()
	local ok, local_overrides = pcall(dofile, local_config)
	if ok and type(local_overrides) == "function" then
		local_overrides(config)
	end
end

return config
