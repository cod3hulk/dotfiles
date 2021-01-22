"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set signcolumn=yes

" Enable line numbers
set number
set relativenumber

" Paste yanked text to global clipboard
set clipboard=unnamedplus

" Ignore case when searching
set ignorecase

" Set colorscheme
colorscheme dracula

" More natural split opening
set splitbelow
set splitright

" Using spaces instead of tabs
set expandtab

" Enable smart tabs
set smarttab

" 1 tab == 4 spaces
set shiftwidth=2
set tabstop=2

" disable folding
set nofoldenable

" enable incremental search
set incsearch
set hls

" scroll offset
set scrolloff=10

" completion menu
set completeopt=longest,menuone

" set cursor
" set guicursor=a:blinkwait700-blinkon400-blinkoff250

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader mapping
let mapleader = "\<SPACE>"
let g:mapleader = "\<SPACE>"

" Fast visual mode
imap fd <Esc>
imap jj <Esc>

" remove higlight for search results
" nmap <cr> :nohlsearch<cr>
nnoremap <CR> :nohlsearch<CR>
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>

" Fast saving
nmap <leader>w :update<cr>
nmap <SPACE>w :update<cr>

" Fast quitting
nmap <leader>q :q<cr>
nmap <SPACE>q :q<cr>

" Fast saving and quitting
nmap <leader>x :x<cr>
nmap <SPACE>x :x<cr>

" Close all buffers but this one
nmap <SPACE>bm :BufOnly<cr>

" Replace for word under cursor
nmap <SPACE>r :%s /\<<C-r><C-w>\>/

if has('nvim')
    nmap <BS> :TmuxNavigateLeft<cr>
endif

" tab completion
inoremap <silent> <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" source .vimrc on save
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

augroup markdown_conf
    " enable spell check
    command! SpellEN setlocal spell spelllang=en_us
    command! SpellDE setlocal spell spelllang=de_de
    command! NoSpell set nospell
augroup END

augroup general_conf
    " enable spell check
    command! Difft windo difft
    command! Diffo windo diffo
    command! Cdc cd %:p:h
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" source .vimrc on save
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

augroup markdown_conf
    " enable spell check
    command! SpellEN setlocal spell spelllang=en_us
    command! SpellDE setlocal spell spelllang=de_de
    command! NoSpell set nospell
augroup END

augroup general_conf
    " enable spell check
    command! Difft windo difft
    command! Diffo windo diffo
    command! Cdc cd %:p:h
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Diff colors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
