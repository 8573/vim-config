" Settings for editing English text.

setlocal expandtab
setlocal formatoptions+=t
setlocal spell

if !&textwidth
	setlocal textwidth=78
endif

autocmd Syntax <buffer>
	\ syntax match vimrcUnicodeCharacterId "\<U+\x\+" contains=@NoSpell
