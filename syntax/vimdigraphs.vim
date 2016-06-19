scriptencoding utf-8

" Syntax hilighting for my `rc/digraphs.vim` file.
"
" Applying Vim’s own vim.vim syntax highlighting to this file is problematic,
" due to Vim not recognizing that special characters in the digraph
" definitions aren’t really special.
"
" Thus, I defined this simple syntax highlighing scheme, which highlights only
"    (a) `dig[raphs]` commands, and
"    (b) VimScript comments.

syntax match VimDigraphsKw '\v^dig%[raphs]'
syntax match VimDigraphsDg '\v%(^dig%[raphs])@<=\s+\zs[^\s_]\S+\ze\s+'
" Code has only one character.
syntax match VimDigraphsD1 '\v%(^dig%[raphs])@<=\s+\zs[^\s_]\ze\s+'
" Code starts with a low line.
syntax match VimDigraphsD_ '\v%(^dig%[raphs])@<=\s+\zs_\S*\ze\s+'
syntax match VimDigraphsNr '\v%(^dig%[raphs]\s+\S+\s+)@<=\d+'
syntax match VimDigraphsDfn '\v^dig%[raphs]\s+\S+\s+\d+'
	\ contains=VimDigraphs\v%(Kw|D[g1_]|Nr)
syntax match VimDigraphsComment '".*$'

highlight link VimDigraphsKw Keyword
highlight link VimDigraphsDg SpecialKey
highlight link VimDigraphsD1 Todo
highlight link VimDigraphsD_ Error
highlight link VimDigraphsNr Number
highlight link VimDigraphsComment Comment
