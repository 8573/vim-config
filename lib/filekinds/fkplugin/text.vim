" Settings for editing English text.

setlocal formatoptions+=t
setlocal spell

autocmd Syntax <buffer>
	\ syntax match vimrcUnicodeCharacterId "\<U+\x\+" contains=@NoSpell
