local opts = {
  noremap = true,
  silent = true
}

local keymap = vim.api.nvim_set_keymap

-- leader key
keymap('', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- common
keymap('i', 'fd', '<ESC>', opts)
keymap('n', '<CR>', ':nohlsearch<CR>', opts)

-- navigation (handled by vim-tmux-navigator plugin)
keymap('n', '<C-d>', '<C-d>zz', opts)
keymap('n', '<C-u>', '<C-u>zz', opts)

-- move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
-- stop visual selection
keymap("x", "<CR>", "<C-c>", opts)

-- indentation
keymap("x", ">", ">gv", opts)
keymap("x", "<", "<gv", opts)

-- file explorer
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)
