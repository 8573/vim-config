syntax clear

" <https://github.com/jjuran/markdown/blob/master/Markdown.pl>

"let s:uri_hier_part =
"	\ '%('	'//'.s:uri_authority.s:uri_path_abempty.
"	\	'|' .s:uri_path_absolute.
"	\	'|' .s:uri_path_rootless.
"	\	'|' .s:uri_path_empty. ')'
"let s:uri_URI =
"	\ .s:uri_scheme.':' .s:uri_hier_part. '%(\?'.s:uri_query.')?'
"	\	. '%(#'.s:uri_fragment.')?'

syntax match markdownAutoLink
	\ /\v\<%(https?|ftp):[^'">[:space:]]+\>/
	\ contains=markdownLinkURI
syntax match markdownLinkURI
	\ '\v\<\zs.{-}\ze\>'
	\ contains=@NoSpell
	\ contained

syntax match markdownLinkRef '\v\[.{-}\] *\[.{-}\]'
	\ contains=markdownLinkRefId
syntax match markdownLinkRefId '\v\[.{-}\] *\[\zs.{-}\ze\]'
	\ contains=@NoSpell
	\ contained
syntax match markdownLinkTarget '\v^\[.{-}\]: '
	\ contains=markdownLinkTargetId
syntax match markdownLinkTargetId '\v^\[\zs.{-}\ze\]: '
	\ contains=@NoSpell
"execute 'syntax match markdownLink $\v<' .s:uri_URI_reference. '>$'
"	\ 'contains=markdownLinkURI'

syntax match markdownCodeSpan '\v``\_.{-}``|`\_.{-}`'
	\ contains=@NoSpell,markdownCodeBlock
syntax region markdownCodeBlock
	\ start='\v^([ \t]*).*\zs\n\n\ze\z(\1%(    |\t))'
	\ end='\v\z1.*\zs\n\ze%(\n\z1@!|\n?%$)'
	\ contains=@NoSpell
	" This requires a blank line or EOF after a code block, whereas
	" Markdown merely requires a drop in indentation level.

" Only highlights non-rendering elements.

highlight link markdownLinkRefId Identifier
highlight link markdownLinkTargetId Identifier
