call plug#begin('~/.local/share/nvim/plugged')

" Color themes
Plug 'dracula/vim'

" Fuzzy search
Plug 'ctrlpvim/ctrlp.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Vim Tmux Navigation
Plug 'christoomey/vim-tmux-navigator'

" Code formatting
Plug 'sbdchd/neoformat'

" Autocomplete
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

" Support for UNIX shell commands
Plug 'tpope/vim-eunuch'

" Markdown support
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" Surround words
Plug 'tpope/vim-surround'

" Initialize plugin system
call plug#end()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable line numbers
set number

" Paste yanked text to global clipboard
set clipboard=unnamed

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
set shiftwidth=4
set tabstop=4


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

" Easier split navigations
"nnoremap <C-J> <C-W><C-J>
"nnoremap <C-K> <C-W><C-K>
"nnoremap <C-L> <C-W><C-L>
"nnoremap <C-H> <C-W><C-H>

if has('nvim')
    nmap <BS> :TmuxNavigateLeft<cr>
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ctrlp config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_map=''
let g:ctrlp_macth_window='bottom,order:btt,min:1,max:10'
let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_reversed=0
map <leader>f :CtrlP<CR>
map <leader>o :CtrlPBufTag<CR>
map <leader>e :CtrlPBuffer<CR>
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40

" ctrlp ignores
let g:ctrlp_custom_ignore = {
			\ 'dir':  '\v[\/]\.(git|hg|svn|settings|project)$',
			\ 'file': '\v\.(exe|so|dll|class)$',
			\ }

" ctrlp cache directory
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'

" ctrlp use silver_searcher for fuzzy searchh
if executable('ag')
	let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
	set grepprg=ag\ --nogroup\ --nocolor
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" youcomplete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt-=preview

