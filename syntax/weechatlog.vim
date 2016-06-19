scriptencoding utf-8

source ~/.vim/syntax/irclog-dyn.vim

function! s:apply()

for s:s in MatchesInBufferSansEmptiesAndDups('\v\<[@+ %~*]?\zs\k+\ze\>|[\t ]-?\*-?[\t ]\zs\k+|[\t ]Notice\(\zs\k+\ze\)')
	call HighlightIrcNick(s:s,
		\ '"\v\<[@+ %~*]?', '>"', '" -\?\*-\? ', ' "', '"\v%(Notice\(| -)', ')\?:"')
endfor

"syntax match WeechatLogTimestamp '\v^.{-}\ze%(\<[@+ %~*]?\k+\>|\<+--+|--+\>+|-+!+-+|[\t ]-?\*-?[\t ]\k+) '
execute 'syntax match WeechatLogTimestamp "\v^.{-}\ze%(\<[@+ %~*]?\k+\>|\<+--+|--+\>+|-+!+-+|[\t ]-?\*-?[\t ]\k+|-\k+:'
	\ . b:ircChanPat . '-)"'
syntax match WeechatLogInfo '\v%(\<+--+|--+\>+|-+!+-+)[\t ].*$'
	\ contains=WeechatLogNotice
syntax match WeechatLogMessage '\v\<[@+ %~*]?\k+\>[\t ].*$'
	\ contains=IrcLogNickMessage.*
syntax match WeechatLogAction '\v[\t ]-?\*-?[\t ]\k+ .*$'
	\ contains=IrcLogNickAction.*
syntax match WeechatLogNotice '\v-+!+-+[\t ]\zsNotice\(\k+\): .*$'
	\ contains=WeechatLogNoticeMarker
execute 'syntax match IrssiLogNotice "\v\d +\zs-\k+:' . b:ircChanPat . '- .*$"'
	\ 'contains=IrcLogNickNotice.*'
syntax match WeechatLogNoticeMarker 'Notice(\k\+):'
	\ contains=IrcLogNickNotice.*
	\ contained
syntax match WeechatLogComment '\v^---.*|^\[\_.{-}\]$'

highlight link WeechatLogInfo IrcLogInfo
highlight link WeechatLogTimestamp IrcLogTimestamp
highlight link WeechatLogMessage IrcLogMessage
highlight link WeechatLogAction IrcLogAction
highlight link WeechatLogNotice IrcLogMessage
highlight WeechatLogNoticeMarker ctermfg=darkgreen
highlight link WeechatLogComment IrcLogComment

" Yes, this belongs in a ftplugin, but it uses `\k`, which is defined in
" `syntax/irclog-dyn.vim`.
let &l:showbreak = repeat(' ', 4 + len(matchstr(GetBufferText(),
	\ '\v\n\zs[^\n]{-}\ze%(\<[@+ %~*]?\k+\>|\<+--+|--+\>+|-+!+-+|[\t ]-?\*-?[\t ]\k+|\d +\zs-\k+:'
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
