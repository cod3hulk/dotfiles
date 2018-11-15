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
Plug 'godlygeek/tabular', { 'for': 'markdown' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Auto colose and surround
Plug 'jiangmiao/auto-pairs'

" Easy uncomment/comment
Plug 'scrooloose/nerdcommenter'

" Python support
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }

" CSV support
Plug 'chrisbra/csv.vim', { 'for': 'csv' }

" GO Support
Plug 'fatih/vim-go', { 'for': 'go' }

" Silver searcher support
Plug 'rking/ag.vim'

" Easymotion
Plug 'easymotion/vim-easymotion'

" Easy align
Plug 'junegunn/vim-easy-align'

" Git support
Plug 'tpope/vim-fugitive'

" Typescript
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

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
set shiftwidth=2
set tabstop=2

" disable folding
set nofoldenable

" enable incremental search
set incsearch

" scroll offset
set scrolloff=10

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader mapping
let mapleader = ","
let g:mapleader = ","

" Fast visual mode
imap fd <Esc>
imap jj <Esc>

" remove higlight for search results
nmap <cr> :nohlsearch<cr>

" Fast saving
nmap <leader>w :update<cr>
nmap <SPACE>w :update<cr>

" Fast quitting
nmap <leader>q :q<cr>
nmap <SPACE>q :q<cr>

" Fast saving and quitting
nmap <leader>x :x<cr>
nmap <SPACE>x :x<cr>

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
map <SPACE>ff :CtrlP<CR>
map <leader>ff :CtrlP<CR>
map <leader>o :CtrlPBufTag<CR>
map <leader>e :CtrlPBuffer<CR>
map <SPACE>fr :CtrlPMRUFiles<CR>
map <leader>fr :CtrlPMRUFiles<CR>
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" youcomplete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt-=preview
let g:ycm_min_num_of_chars_for_completion = 4
let g:ycm_min_num_identifier_candidate_chars = 4
let g:ycm_enable_diagnostic_highlighting = 0
" Don't show YCM's preview window [ I find it really annoying ]
set completeopt-=preview
let g:ycm_add_preview_to_completeopt = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" easymotion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <SPACE>jj <Plug>(easymotion-bd-f)
map <leader>e <Plug>(easymotion-bd-f)
let g:EasyMotion_smartcase = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" source .vimrc on save
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

augroup python_conf
    " add breakpoint
    autocmd FileType python nmap <leader>b Oimport ipdb; ipdb.set_trace()<esc>
    " delete all breakpoints
    autocmd FileType python command DelBreaks execute "g/import ipdb; ipdb.set_trace()/d"
augroup END

augroup markdown_conf
    " enable spell check
    command! Spell setlocal spell spelllang=en_us
    command! NoSpell set nospell
augroup END


" TODO better diff colors
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

