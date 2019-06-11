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
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

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

" Typescrip
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

" Surround support
Plug 'tpope/vim-surround'

" Tab support
Plug 'gcmt/taboo.vim'

" Snippets
Plug 'SirVer/ultisnips'

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
set hls

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
map <SPACE>fb :CtrlPBuffer<CR>
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
" deoplete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:deoplete#enable_at_startup = 1
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ultisnips
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsExpandTrigger="<c-k>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.nvim/snippets']
let g:UltiSnipsEditSplit="vertical"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" neosnippet
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
"imap <C-k>     <Plug>(neosnippet_expand_or_jump)
"smap <C-k>     <Plug>(neosnippet_expand_or_jump)
"xmap <C-k>     <Plug>(neosnippet_expand_target)

"" For conceal markers.
"if has('conceal')
  "set conceallevel=2 concealcursor=niv
"endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" neosnippet
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable snipMate compatibility feature.
"let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
"let g:neosnippet#snippets_directory='~/.snippets'

"let g:neosnippet#disable_runtime_snippets = {
        "\   '_' : 1,
        "\ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" easymotion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <SPACE>jj <Plug>(easymotion-bd-f)
map <leader>e <Plug>(easymotion-bd-f)
let g:EasyMotion_smartcase = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" neoformat
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:neoformat_xml_tidy = {
        \ 'exe': 'tidy',
        \ 'args': ['-quiet',
        \          '-xml',
        \          '-utf8',
        \          '--indent auto',
        \          '--indent-attributes yes',
        \          '--indent-spaces ' . shiftwidth(),
        \          '--tidy-mark no',
        \          '--vertical-space yes',
        \          '--wrap 0',
        \         ],
        \ 'stdin': 1,
        \ 'valid_exit_codes': [0, 1],
        \ }

let g:neoformat_javascript_jsbeautify = {
            \ 'exe': 'jsbeautify',
            \ 'args': ['-s 4', '-E'],
            \ 'replace': 1,
            \ 'stdin': 1,
            \ 'env': ["DEBUG=0"],
            \ 'valid_exit_codes': [0, 23],
            \ 'no_append': 1
            \ }

" Enable alignment
let g:neoformat_basic_format_align = 1
" Enable tab to spaces conversion
let g:neoformat_basic_format_retab = 1
" Enable trimmming of trailing whitespace
let g:neoformat_basic_format_trim = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" source .vimrc on save
augroup reload_vimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

"augroup python_conf
    "" add breakpoint
    "autocmd FileType python nmap <leader>b Oimport ipdb; ipdb.set_trace()<esc>
    "" delete all breakpoints
    "autocmd FileType python command DelBreaks execute "g/import ipdb; ipdb.set_trace()/d"
"augroup END

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

" TODO better diff colors
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red


