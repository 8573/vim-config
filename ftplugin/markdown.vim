scriptencoding utf-8

noremap <buffer> <silent> <Leader>ih1 :MDInsertHeader1<CR>
noremap <buffer> <silent> <Leader>ih2 :MDInsertHeader2<CR>

command! MDInsertHeader1 execute 'normal' &textwidth . 'i='
command! MDInsertHeader2 execute 'normal' &textwidth . 'i-'

noremap <buffer> <silent> <Leader>zq>    :MDEnquote<CR>
noremap <buffer> <silent> <Leader>zq<lt> :MDDequote<CR>
noremap <buffer> <silent> <Leader>zQ>    :MDEnquote<CR>gq
noremap <buffer> <silent> <Leader>zQ<lt> :MDDequote<CR>gq
vnoremap <buffer> <silent> <Leader>zQ>    :MDEnquote<CR>gvgq
vnoremap <buffer> <silent> <Leader>zQ<lt> :MDDequote<CR>gvgq

command! -range MDEnquote <line1>,<line2>substitute:\m^:> : | nohlsearch
command! -range MDDequote <line1>,<line2>substitute:\m^> :: | nohlsearch

let b:vimpipe_command = 'multimarkdown'
let b:vimpipe_filetype = 'html'
