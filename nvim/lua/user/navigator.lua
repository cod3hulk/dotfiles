-- Smart pane navigation: ctrl+h/j/k/l moves between Neovim windows, and at a
-- window edge hands off to the surrounding multiplexer (Herdr, or tmux as a
-- fallback). This replaces christoomey/vim-tmux-navigator with a
-- multiplexer-agnostic local navigator so the same keybindings work inside
-- Herdr without the plugin's tmux-only escape sequences.
--
-- The multiplexer side is the other half of the loop:
--   * Herdr: herdr/scripts/navigate.sh intercepts ctrl+hjkl upstream and, when
--     the focused pane is running nvim, forwards the key here with
--     `herdr pane send-keys`. So in a shell pane, ctrl+hjkl focuses the
--     neighbouring Herdr pane directly; in nvim, the key reaches this map.
--   * tmux: the vim-tmux-navigator tmux plugin (still in tmux.conf) does the
--     equivalent is_vim passthrough for tmux sessions.
--
-- At a nvim window edge we call `herdr pane focus --direction <dir>` when
-- $HERDR_ENV is set, otherwise fall back to `tmux select-pane` when $TMUX is
-- set, otherwise do nothing (plain wincmd already ran).
local M = {}

-- nvim wincmd letter -> multiplexer direction
local DIRS = {
  h = { win = "h", herdr = "left",  tmux = "l" },
  j = { win = "j", herdr = "down",  tmux = "D" },
  k = { win = "k", herdr = "up",    tmux = "U" },
  l = { win = "l", herdr = "right", tmux = "R" },
}

local function handoff(d)
  if vim.env.HERDR_ENV == "1" and vim.fn.executable("herdr") == 1 then
    vim.fn.system({ "herdr", "pane", "focus", "--direction", d.herdr })
  elseif vim.env.TMUX and vim.fn.executable("tmux") == 1 then
    vim.fn.system({ "tmux", "select-pane", "-t", vim.env.TMUX_PANE, "-" .. d.tmux })
  end
end

function M.navigate(key)
  local d = DIRS[key]
  if not d then return end
  local before = vim.fn.winnr()
  vim.cmd("wincmd " .. d.win)
  -- wincmd is a no-op at a window edge: the window number does not change,
  -- so ask the multiplexer to move to its neighbouring pane instead.
  if vim.fn.winnr() == before then
    handoff(d)
  end
end

function M.setup()
  for key in pairs(DIRS) do
    vim.keymap.set("n", "<C-" .. key .. ">", function() M.navigate(key) end,
      { silent = true, desc = "smart pane navigate " .. key })
  end
  -- Previous window / pane. Inside nvim this is `wincmd p`; at the edge it is
  -- a no-op, so there is nothing useful to hand off for the previous-pane
  -- concept across multiplexers.
  vim.keymap.set("n", "<C-\\>", "<C-W>p", { silent = true, desc = "previous window" })
end

return M
