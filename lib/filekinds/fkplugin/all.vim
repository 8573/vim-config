" Settings for all files, to be applied after filetype, and filekind, plugins
" run.

if exists('+breakindent') && &breakindent && exists('+showbreak')
	let s:i = &tabstop ? &tabstop : &shiftwidth
	let s:i = ((s:i ? s:i : &softtabstop) / 2) - 1
	let s:i = s:i <= 3 ? s:i : 3
	let &l:showbreak = [' ', '┈ ', '┈  ', ' ┈  '][s:i]
	" That’s…
	"     .   :.   :..   .:..
	" …with `:` being a U+2508 BOX DRAWINGS LIGHT QUADRUPLE DASH
	" HORIZONTAL and `.` being a U+00A0 NO-BREAK SPACE.
endif

if ((v:version == 703 && !has('patch629')) || v:version < 703)
		\ && &tabstop && !&shiftwidth
	" Won’t reflect changes to &tabstop, but better than nothing.
	let &l:shiftwidth = &tabstop
endif

if &shiftwidth && !&tabstop
	let &l:tabstop = &shiftwidth
endif

if !&l:modifiable || &l:readonly
	setlocal colorcolumn=0
	setlocal nospell
endif
