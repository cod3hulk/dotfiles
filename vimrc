"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle config 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" Bundles
Bundle 'gmarik/vundle'
Bundle 'kien/ctrlp.vim'
" Bundles for colors
Bundle 'tomasr/molokai'
Bundle 'altercation/vim-colors-solarized'
" Bundles for Snippets
Bundle 'tomtom/tlib_vim'
Bundle 'MarcWeber/vim-addon-mw-utils'
Bundle 'garbas/vim-snipmate'
Bundle 'honza/vim-snippets'
" Bundle 'vim-ruby/vim-ruby'
" Bundle 'thoughtbot/vim-rspec'
" Bundle 'tpope/vim-surround'
" Bundle 'ervandew/supertab'
" Bundle 'tpope/vim-fugitive'
" Bundle 'tpope/vim-endwise'

filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" general config 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set how many lines of history VIM has to remember
set history=700

" Set relative line number
set relativenumber

" Set to auto read when a file is changed from the outside
set autoread

" Paste yanked text to global clipboard
set clipboard=unnamed

" Always show current position
set ruler

" Set offset lines when moving cursor
set so=10

" Enable wild menu
set wildmenu

" Ignore compiled files from wildmenu
set wildignore=*/target/*

" set wildmode
set wildmode=longest,list

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

" disable search wrap around the end of file
set nows

" gvim settings
if has("gui_running")
    " remove menu bar
    set guioptions-=m  

    " remove toolbar
    set guioptions-=T  

    " remove right-hand scroll bar
    set guioptions-=r  

    " remove left-hand scroll bar
    set guioptions-=L  

    " maximize gvim window.
    set lines=999 columns=999
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set color theme for gvim only
if has("gui_running")
   colorscheme molokai
else
   colorscheme molokai
   set background=dark
endif

" Set font size
if has("gui_running")
    if has("gui_gtk2")
        set guifont=Inconsolata\ 12
    elseif has("gui_macvim")
        set guifont=Menlo\ Regular:h14
    elseif has("gui_win32")
        set guifont=Consolas:h11:cANSI
    endif
endif

" Enable syntax highlighting
syntax enable

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = ","
let g:mapleader = ","

" always clear screen when executing a command
" map :! :!clear;

" remove higlight for search results
nmap <cr> :nohlsearch<cr>

" Fast saving
nmap <leader>w :update<cr>

" Fast quitting
nmap <leader>q :q<cr>

" Fast saving and quitting
nmap <leader>x :x<cr>

" Fast visual mode
imap jj <Esc>

" Move a line of text using Shift+[jk]
"nmap <S-j> mz:m+<cr>`z
"nmap <S-k> mz:m-2<cr>`z
"vmap <S-j> :m'>+<cr>`<my`>mzgv`yo`z
"vmap <S-k> :m'<-2<cr>`>my`<mzgv`yo`z

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Show full path of current file
set statusline=%F%m%r%h%w\ %{fugitive#statusline()}\ [%l,%c]\ [%L,%p%%]
" set statusline =%3*%y%*                "file type

" Always show status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ctrlp config 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ctrlp config
let g:ctrlp_map='<leader>f'
let g:ctrlp_max_height=30
let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_reversed=0

let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn|settings|project)$',
            \ 'file': '\v\.(exe|so|dll|class)$',
            \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" supertab config 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:SuperTabDefaultCompletionType = "context"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ruby related stuff 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" execute current ruby script
autocmd FileType ruby nmap <leader>r :!ruby %<cr>

" execute ri for the the word under the cursor
autocmd FileType ruby nmap <leader>h :!ri <cword><cr>

" executing rspec files
autocmd FileType ruby map <leader>t :call RunCurrentSpecFile()<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" shell script related stuff 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType sh nmap <leader>r :w<cr> :!%:p<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" gradle stuff 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType groovy nmap <leader>r :w<cr> :!gradle<cr>
au BufRead,BufNewFile *.gradle set filetype=groovy

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" javascript stuff 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType javascript nmap <leader>r :w<cr> :!node %<cr>

