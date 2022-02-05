require'nvim-tree'.setup {
  disable_netrw = false,
  hijack_netrw = false
}

vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true, noremap = true })

-- nnoremap <leader>e :NvimTreeToggle<CR>
