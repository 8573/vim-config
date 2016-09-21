scriptencoding utf-8

source ~/.vim/syntax/irclog-dyn.vim

function! s:apply()

for s:s in MatchesInBufferSansEmptiesAndDups('\v\<[@+ %*]?\zs\k+\ze\>| \* \zs\k+')
	call HighlightIrcNick(s:s,
		\ '"\v\<[@+ %*]?', '>"', '" \* ', ' "', '"-', ':"')
endfor

"syntax match IrssiLogTimestamp '\v^.{-}\ze%(\<[@+ %*]?\k+\>|-!-| \* \k+) '
execute 'syntax match IrssiLogTimestamp "\v^.{-}\ze%(\<[@+ %*]?\k+\>|-!-| \* \k+|-\k+:'
	\ . b:ircChanPat . '-)"'
syntax match IrssiLogInfo '-!- .*$'
syntax match IrssiLogMessage '\v\<[@+ %*]?\k+\> .*$'
	\ contains=IrcLogNick.*
syntax match IrssiLogAction '\v \* \k+ .*$'
	\ contains=IrcLogNick.*
execute 'syntax match IrssiLogNotice "\v-\k+:' . b:ircChanPat . '- .*$"'
	\ 'contains=IrcLogNick.*'
syntax match IrssiLogComment '\v^---.*|^\[\_.{-}\]$'

highlight link IrssiLogInfo IrcLogInfo
highlight link IrssiLogTimestamp IrcLogTimestamp
highlight link IrssiLogMessage IrcLogMessage
highlight link IrssiLogAction IrcLogAction
highlight link IrssiLogComment IrcLogComment

" Yes, this belongs in a ftplugin, but it uses `\k`, which is defined in
" `syntax/irclog-dyn.vim`.
let &l:showbreak = repeat(' ', 4 + len(matchstr(GetBufferText(),
	\ '\v\n\zs[^\\n]{-}\ze%(\<[@+ %*]?\k+\>|-!-| \* \k+|-\k+:'
	\ . b:ircChanPat . '-)')))
let &l:breakat = ' '

if exists('s:s')
	unlet s:s
endif

endfunction

if @% !~ '*\.\v%(gz|bz2|xz|lzma|Z)'
	call s:apply()
endif
autocmd BufReadPost <buffer> call s:apply()
