call DfnInsertMacro('TM', 'TeXLeaderInsAlignEnv()')
call DfnInsertMacro('TE', 'TeXLeaderInsEnv()')

function! TeXLeaderInsAlignEnv()
	return "\\begin{align}\n%\n\\end{align}\<Up>\<End>\<BS>"
endfunction

function! TeXLeaderInsEnv()
	let l:e = PromptLine('Name of environment to insert: ')
	return '\begin{' .. l:e .. "}\n%\n\\end{" .. l:e
		\ .. "}\<Up>\<End>\<BS>"
endfunction
