call plug#begin('~/.local/share/nvim/plugged')

" Color themes
Plug 'dracula/vim'

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable true colors
" set termguicolors

" Set colorscheme
colorscheme dracula

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Leader mapping
let mapleader = ","
let g:mapleader = ","

" Fast visual mode
imap jj <Esc>

" remove higlight for search results
nmap <cr> :nohlsearch<cr>

" Fast saving
nmap <leader>w :update<cr>

" Fast quitting
nmap <leader>q :q<cr>

" Fast saving and quitting
nmap <leader>x :x<cr>

