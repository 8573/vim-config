" Settings for writing, e.g., email messages and version-control-system commit
" messages.

call SetFileKind('text')

setlocal expandtab

if !&shiftwidth
	setlocal shiftwidth=4
endif

if &textwidth > 70
	setlocal textwidth=70
endif
