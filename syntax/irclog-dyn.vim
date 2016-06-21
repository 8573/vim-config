scriptencoding utf-8

" Common syntax highlighting definitions for IRC log formats.
"
" This does not define any syntax rules itself, but rather only provides
" highlight groups to be used by, e.g., `irssilog.vim`.
"
" Supports coloring different nicks differently (within the limits of the
" color palette).

let s:HighlightNicksEverywhere = 0

highlight link IrcLogMessage Normal
highlight link IrcLogAction IrcLogMessage

execute 'highlight IrcLogInfo ctermfg=' . (&t_Co == 256 ? 60 : 8)
highlight link IrcLogClientInfo IrcLogInfo
highlight link IrcLogServerInfo IrcLogInfo

execute 'highlight IrcLogComment ctermfg=' . (&t_Co == 256 ? 247 : 8)

highlight IrcLogTimestamp ctermfg=8


" Colors (of the 256-color palette) that look bad when applied to IRC nicks in
" IRC log syntax highlighting.
let s:grays = [7,8,15,16,17,18,19,20,59,60,61,102,103]
let s:pales = [144,145,146,147,176,181,182,183,188,189,223,224,225]
let s:badColors = &t_Co == 256 ? [0] + s:grays + s:pales : [0]
unlet s:grays s:pales

let s:m = &t_Co == 256 ? 228 : &t_Co

" Characters valid in nicks.
setlocal iskeyword=a-z,A-Z,45,48-57,91-96,123-125

function! HighlightIrcNick(
		\ nick, msgPre, msgPost, actPre, actPost,
		\ noticePre, noticePost)
	" The highlight color must not depend on anything other than (a) the
	" nick string, or (b) constant data (e.g., `s:badColors`). E.g., I
	" previously kept a list of colors that had already been assigned to
	" nicks, and tried to avoid selecting an already-assigned color, but I
	" removed this check because I realized that it could entail
	" highlighting a nick differently in different log files based on the
	" presence or abscence of other nicks, or even whether or not someone
	" used `/me`.
	let l:nickPat = VerbatimPattern(a:nick)
	let l:hash = Hash(a:nick)
	let l:nick = matchstr(a:nick, '\a\+')
	if l:nick == '' || l:nick == 'Guest'
		let l:nick = substitute(a:nick, '[_`]', '', 'g')
	endif
	let l:c = 0
	while IsInList(s:badColors, l:c)
		let l:c = abs(str2nr(SHA256(l:nick), 16) % s:m)
		let l:nick .= NrToChar(1 + (l:c % 126), 1)
	endwhile
	if s:HighlightNicksEverywhere
		execute 'syntax match IrcLogNickMention'.l:hash
			\ '"\<' . l:nickPat . '\>"'
			\ 'display contained '
		execute 'highlight IrcLogNickMention'.l:hash 'ctermfg='.l:c
	else
		execute 'syntax match IrcLogNickMessage'.l:hash
			\ a:msgPre . '\zs' . l:nickPat . '\m\ze' . a:msgPost
			\ 'display contained'
		execute 'syntax match IrcLogNickAction'.l:hash
			\ a:actPre . '\zs' . l:nickPat . '\m\ze' . a:actPost
			\ 'display contained'
		if a:noticePre != '' || a:noticePost != ''
			execute 'syntax match IrcLogNickNotice'.l:hash
				\ a:noticePre . '\zs' . l:nickPat . '\m\ze'
				\ . a:noticePost 'display contained'
		endif
		execute 'highlight IrcLogNickMessage'.l:hash 'ctermfg='.l:c
		execute 'highlight link IrcLogNickAction'.l:hash
			\ 'IrcLogNickMessage'.l:hash
		if a:noticePre != '' || a:noticePost != ''
			execute 'highlight link IrcLogNickNotice'.l:hash
				\ 'IrcLogNickMessage'.l:hash
		endif
	endif
endfunction

" So that `contains=IrcLogNick.*` doesn’t error out if no nick highlight rules
" have been defined (e.g., if there aren’t any nicks in the file).
highlight link IrcLogNick Normal
highlight link IrcLogNickMention Normal
highlight link IrcLogNickMessage Normal
highlight link IrcLogNickAction Normal
highlight link IrcLogNickNotice Normal

let b:ircChanPat = '\v%([#+&]|!%(\u|\d){5})[^ ,:\n\r\x00\x07]{,49}%(:[^ ,:\n\r\x00\x07]{,49})?'

" Belongs in a ftplugin, but I don’t want to bother waiting for another file
" to be read.
setlocal autoread
" Refresh
noremap <buffer> <Leader>r :checktime<CR>
if exists(':HideBadWhitespace') == 2 && &l:readonly
	HideBadWhitespace
endif
