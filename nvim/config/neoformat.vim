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
