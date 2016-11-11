scriptencoding utf-8

source ~/.vim/syntax/irclog-dyn.vim

function! s:apply()

for s:s in MatchesInBufferSansEmptiesAndDups('\v\<[@+ %~*&!]?\zs\k+\ze\>| \* \zs\k+\ze|\[\zs\k+\ze\]')
	call HighlightIrcNick(s:s,
		\ '"\v\<[@+ %~*&!]?', '>"', '"-\*- ', ' "', '"\[', '\]"')
endfor

"syntax match QuasselLogTimestamp "\v^\[[^]]+\]\ze %(\<[@+ %~*&!]?\k+\>|[-<>*=]{1,3}|\[\k+\])"
syntax match QuasselLogTimestamp "\v^\[[^\]]+\]\ze "
syntax match QuasselLogInfo '\v[-<>*=]{1,3} .*$'
syntax match QuasselLogMessage '\v\<[@+ %~*&!]?\k+\> .*$'
	\ contains=IrcLogNickMessage.*
syntax match QuasselLogAction '\v-\*- \k+ .*$'
	\ contains=IrcLogNickAction.*
syntax match IrssiLogNotice "\[\k+\] .*$"
	\ contains=IrcLogNickNotice.*
syntax match QuasselLogComment '\v^---.*|^\[.*\]$'

highlight link QuasselLogInfo IrcLogInfo
highlight link QuasselLogTimestamp IrcLogTimestamp
highlight link QuasselLogMessage IrcLogMessage
highlight link QuasselLogAction IrcLogAction
highlight link QuasselLogComment IrcLogComment

" Yes, this belongs in a ftplugin, but it uses `\k`, which is defined in
" `syntax/irclog-dyn.vim`.
let &l:showbreak = repeat(' ', 4 + len(matchstr(GetBufferText(),
	\ '\v\n\zs\[[^]]+\]\ze ')))
let &l:breakat = ' '

if exists('s:s')
	unlet s:s
endif

endfunction

if @% !~ '*\.\v%(gz|bz2|xz|lzma|Z)'
	call s:apply()
endif
autocmd BufReadPost <buffer> call s:apply()
