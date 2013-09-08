"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: Tomas Avé
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set how many lines of history VIM has to remember
set history=700

" Set relative line number
set relativenumber

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" Fast saving
nmap <leader>w :update<cr>

" Fast quitting
nmap <leader>q :q<cr>

" Fast visual mode
imap jj <Esc> 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Always show current position
set ruler

" Set offset lines when moving cursor
set so=7

" Enable wild menu
set wildmenu

" Ignore compiled files from wildmenu
set wildignore=*.class

" Height of the command bar
set cmdheight=2

" Ignore case when searching
set ignorecase

" Enable smart case or searching
set smartcase

" Higlight search results
set hlsearch

" Incremental search
set incsearch

" Turn on magic for regular expressions
set magic

" Show matching brackets
set showmatch

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Set color theme
set background=dark
colorscheme solarized

" Set default encoding
set encoding=utf-8

" Set file format handling
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text, tab and ident related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Using spaces instead of tabs
set expandtab

" Enable smart tabs
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

" Enable auto indent
set autoindent

" Enable smart indent
set smartindent

" Enable wrap lines
set wrap
