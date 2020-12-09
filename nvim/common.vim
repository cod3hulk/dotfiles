source $HOME/.config/nvim/config/plugin.vim
source $HOME/.config/nvim/config/common.vim



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
let g:deoplete#sources#go#gocode_binary = '$HOME/go/bin/gocode'
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ultisnips
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsExpandTrigger="<c-k>"
let g:UltiSnipsJumpForwardTrigger="<c-k>"
let g:UltiSnipsJumpBackwardTrigger="<c-j>" 
let g:UltiSnipsSnippetDirectories=[$HOME.'/.nvim/snippets']
let g:UltiSnipsEditSplit="vertical"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" plantuml
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:plantuml_executable_script = 'plantuml'
au FileType plantuml let g:plantuml_previewer#plantuml_jar_path = get(
    \  matchlist(system('cat `which plantuml` | grep plantuml.jar'), '\v.*\s[''"]?(\S+plantuml\.jar).*'),
    \  1,
    \  0
    \)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" easymotion
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <SPACE>jj <Plug>(easymotion-bd-f)
map <leader>e <Plug>(easymotion-bd-f)
let g:EasyMotion_smartcase = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nerdcommenter
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <SPACE>cc <Plug>NERDCommenterToggle
nmap <SPACE>c<SPACE> <Plug>NERDCommenterComment

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


" TODO better diff colors
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
