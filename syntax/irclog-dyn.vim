scriptencoding utf-8

" Common syntax highlighting definitions for IRC log formats.
"
" This does not define any syntax rules itself, but rather only provides
" highlight groups to be used by, e.g., `irssilog.vim`.
"
" Supports coloring different nicks differently (within the limits of the
" color palette).

let s:HighlightNicksEverywhere = 1

highlight link IrcLogMessage Normal
highlight link IrcLogAction IrcLogMessage

execute 'highlight IrcLogInfo ctermfg=' . (&t_Co == 256 ? 60 : 8)
	\ . ' guifg=#5F5F87'
highlight link IrcLogClientInfo IrcLogInfo
highlight link IrcLogServerInfo IrcLogInfo

execute 'highlight IrcLogComment ctermfg=' . (&t_Co == 256 ? 247 : 8)
	\ . ' guifg=#9E9E9E'

highlight IrcLogTimestamp ctermfg=8 guifg=#5C5C5C

" The highlight color for a nick must not depend on anything other than (a)
" the nick string, or (b) constant data (e.g., `s:badColors`). E.g., I
" previously kept a list of colors that had already been assigned to nicks,
" and tried to avoid selecting an already-assigned color, but I removed this
" check because I realized that it could entail highlighting a nick
" differently in different log files based on the presence or abscence of
" other nicks, or even whether or not someone used `/me`.

" Colors (of the 256-color palette) that look bad when applied to IRC nicks in
" IRC log syntax highlighting.
let s:grays = [7,8,15,16,17,18,19,20,59,60,61,102,103]
let s:pales = [144,145,146,147,176,181,182,183,188,189,223,224,225]
let s:badColors = &t_Co == 256 ? [0] + s:grays + s:pales : [0]
unlet s:grays s:pales

let s:goodColorModulus = &t_Co == 256 ? 228 : &t_Co

if has('gui_running')
	let s:hlFmtType = 'guifg='
	let s:zeroColor = [0, 0, 0]

	function! s:color_fmt(color)
		return printf('guifg=#%02X%02X%02X',
			\ a:color[0], a:color[1], a:color[2])
	endfunction

	function! s:color_is_bad(color)
		return s:color_too_dark(a:color)
			\ || s:color_lacks_contrast(a:color)
	endfunction

	function! s:color_from_nick(nick)
		let l:r = s:color_part(a:nick, 'R')
		let l:g = s:color_part(a:nick, 'G')
		let l:b = s:color_part(a:nick, 'B')

		return [l:r, l:g, l:b]
	endfunction

	function! s:color_too_dark(color)
		return s:color_sum(a:color) < 384
	endfunction

	function! s:color_lacks_contrast(color)
		for l:a in a:color
			for l:b in a:color
				if abs(l:a - l:b) > 160
					return 0
				endif
			endfor
		endfor
		return 1
	endfunction

	function! s:color_sum(color)
		return a:color[0] + a:color[1] + a:color[2]
	endfunction

	function! s:color_part(nick, part)
		return abs(SHA256AsNr(a:nick . a:part) % 256)
	endfunction
else
	let s:zeroColor = 0

	function! s:color_fmt(color)
		return 'ctermfg=' . a:color
	endfunction

	function! s:color_is_bad(color)
		return IsInList(s:badColors, a:color)
	endfunction

	function! s:color_from_nick(nick)
		return abs(SHA256AsNr(a:nick) % s:goodColorModulus)
	endfunction

	function! s:color_sum(color)
		return a:color
	endfunction
endif

function! s:highlight_fmt(nick)
	let l:nick = matchstr(a:nick, '\a\+')
	if l:nick == '' || l:nick == 'Guest'
		let l:nick = substitute(a:nick, '[_`]', '', 'g')
	endif

	let l:color = s:zeroColor

	while s:color_is_bad(l:color)
		let l:color = s:color_from_nick(l:nick)
		let l:nick .= NrToChar(1 + (s:color_sum(l:color) % 126), 1)
	endwhile

	return s:color_fmt(l:color)
endfunction

" Characters valid in nicks.
setlocal iskeyword=a-z,A-Z,45,48-57,91-96,123-125

function! HighlightIrcNick(
		\ nick, msgPre, msgPost, actPre, actPost,
		\ noticePre, noticePost)
	let l:nickPat = VerbatimPattern(a:nick)
	let l:hash = Hash(a:nick)
	let l:fmt = s:highlight_fmt(a:nick)
	if s:HighlightNicksEverywhere
		execute 'syntax match IrcLogNick'.l:hash
			\ '"\<' . l:nickPat . '\>"'
			\ 'display contained '
		execute 'highlight IrcLogNick'.l:hash l:fmt
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
		execute 'highlight IrcLogNickMessage'.l:hash l:fmt
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
