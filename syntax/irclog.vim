scriptencoding utf-8

" Common syntax highlighting definitions for IRC log formats.
"
" This does not define any syntax rules itself, but rather only provides
" highlight groups to be used by, e.g., `irssilog.vim`.
"
" Supports coloring different nicks differently (within the limits of the
" color palette).

highlight link IrcLogMessage Normal
highlight link IrcLogAction IrcLogMessage

execute 'highlight IrcLogInfo ctermfg=' . (&t_Co == 256 ? 60 : 8)
highlight link IrcLogClientInfo IrcLogInfo
highlight link IrcLogServerInfo IrcLogInfo

highlight IrcLogTimestamp ctermfg=8

let s:alphabet = map(range(char2nr('A'), char2nr('Z')), 'nr2char(v:val)')
let g:ircNickHighlightSuffixes = ['']
for s:c1 in s:alphabet
	call add(g:ircNickHighlightSuffixes, s:c1)
	for s:c2 in s:alphabet
		call add(g:ircNickHighlightSuffixes, s:c1 . s:c2)
	endfor
endfor
unlet s:alphabet s:c1 s:c2

let [s:n, s:i] = [1, 1]

" Chop off the gray colors at the end of the 256-color palette.
let s:m = &t_Co == 256 ? 228 : &t_Co

" Colors (of the 256-color palette) that look bad when applied to IRC nicks in
" IRC log syntax highlighting.
let s:grays = [7,8,15,16,17,18,19,20,59,60,61,102,103]
let s:pales = [144,145,146,147,176,181,182,183,188,189,223,224,225]
let s:badcolors = &t_Co == 256 ? s:grays + s:pales + [0] : [0]
unlet s:grays s:pales

for s:s in g:ircNickHighlightSuffixes
	" Using separate highlight groups in case I want to have nicks in
	" action messages be formatted differently from nicks in normal
	" messages.
	execute 'highlight IrcLogNick'.s:s 'ctermfg='.s:n
	execute 'highlight IrcLogActionNick'.s:s 'ctermfg='.s:n
	if len(s:s) == 2
		if s:i < 3
			let s:i += 1
		else
			let [s:n, s:i] = [s:n != s:m ? s:n + 1 : 1, 1]
		endif
	endif
	while index(s:badcolors, s:n) != -1
		let s:n += 1
	endwhile
endfor

unlet s:badcolors s:n s:i s:m s:s

" Quite slow without this, presumably due to all the different nick rules.
set nocursorline
