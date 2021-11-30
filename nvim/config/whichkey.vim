nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
set timeoutlen=500

let g:which_key_map = {}

let g:which_key_map['w'] = [ 'w', 'save' ]
let g:which_key_map['q'] = [ 'q', 'quit' ]
let g:which_key_map['x'] = [ 'x', 'save and quit' ]
let g:which_key_map['t'] = [ 't', 'toggle tree' ]

let g:which_key_map.f = {
      \ 'name' : '+find',
      \ 'r' : [ 'CtrlPMRUFiles', 'recent files' ],
      \ 'f' : [ 'CtrlP', 'files' ],
      \ 'b' : [ 'CtrlPBuffer', 'buffer' ],
      \ }

let g:which_key_map.b = {
      \ 'name' : '+buffer',
      \ 'm' : [  'BufOnly', 'close others' ],
      \ }

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
