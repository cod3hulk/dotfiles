require("helpers")
---------------------- Mappings ---------------------- 
g.mapleader = ' '
map('n', '<leader>w', ':update<CR>')
map('i', 'fd', '<ESC>')
map('n', '<CR>', ':nohlsearch<CR>')
map('n', '<leader>q', ':q<cr>')
map('n', '<leader>x', ':x<cr>')

---------------------- General ---------------------- 
opt.number = true
opt.relativenumber = true
opt.clipboard ='unnamedplus'
opt.ignorecase = true
opt.expandtab = true
opt.smarttab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.incsearch = true
opt.hls = true
opt.scrolloff = 10

cmd 'colorscheme dracula'

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])
--[[
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Diff colors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
]]
