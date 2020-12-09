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
