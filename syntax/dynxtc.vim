scriptencoding utf-8

source ~/.vim/syntax/xt256colors.vim

autocmd CursorHold,CursorHoldI <buffer> call ApplyXT256ColorSynHl()

setlocal noswapfile updatetime=250
