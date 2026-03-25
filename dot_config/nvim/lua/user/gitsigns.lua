local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
  return
end

gitsigns.setup({
  signs = {
    add          = { text = "▎" },
    change       = { text = "▎" },
    delete       = { text = "▁" },
    topdelete    = { text = "▔" },
    changedelete = { text = "▎" },
    untracked    = { text = "▎" },
  },
  current_line_blame = false,
  current_line_blame_opts = {
    delay = 500,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local opts = { buffer = bufnr, silent = true }

    -- Hunk navigation
    vim.keymap.set("n", "]h", gs.next_hunk, opts)
    vim.keymap.set("n", "[h", gs.prev_hunk, opts)
  end,
})
