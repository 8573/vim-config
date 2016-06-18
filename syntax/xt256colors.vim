scriptencoding utf-8

function! ApplyXT256ColorSynHl()
	syntax clear
	let l:i = 0
	for l:m in StripDupElems(MatchesInBuffer('\d\+'))
		let l:i += 1
		execute 'syntax match XT256C'.l:i '"\<'.l:m.'\>"'
		execute 'highlight XT256C'.l:i 'ctermfg='.l:m 'ctermbg='.l:m
	endfor
endfunction

call ApplyXT256ColorSynHl()
