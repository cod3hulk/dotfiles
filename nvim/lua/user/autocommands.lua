vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- Dim nvim's background when its tmux pane loses focus, matching the tmux
-- window-style/window-active-style dimming used for regular panes.
-- Requires `focus-events on` in tmux (already set in tmux/tmux.conf).
local active_bg = "#282a36" -- Dracula bg, matches terminal/window-active-style
local inactive_bg = "#1c1d26" -- slightly darker, matches window-style

local function set_bg(color)
  for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer", "LineNr" }) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    if ok then
      hl.bg = color
      pcall(vim.api.nvim_set_hl, 0, group, hl)
    end
  end
end

vim.api.nvim_create_augroup("PaneFocusDim", { clear = true })

vim.api.nvim_create_autocmd("FocusLost", {
  group = "PaneFocusDim",
  callback = function()
    set_bg(inactive_bg)
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  group = "PaneFocusDim",
  callback = function()
    set_bg(active_bg)
  end,
})
