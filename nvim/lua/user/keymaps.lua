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

-- navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- indentation
keymap("x", ">", ">gv", opts)
keymap("x", "<", "<gv", opts)

-- stop visual selection
keymap("x", "<CR>", "<C-c>", opts)


