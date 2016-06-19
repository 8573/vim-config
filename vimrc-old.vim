scriptencoding utf-8

"{{{======== Prolog of Miscellaneous Initialization =================\

set nocompatible

if !exists('g:vimrc_settings_only')

augroup vimrc
autocmd!

if !exists('g:vimrc_NO_PLUGINS')
	runtime rc/gentoo-vimrc.vim
	runtime vim-sensible/plugin/sensible.vim
	runtime rc/digraphs.vim

	" Directory wherein plugins are stored.
	let s:plugin_dir = fnamemodify('~/.vim/bundle', ':p')

	execute pathogen#infect(s:plugin_dir . '/{}')
else
	source ~/.vim/vim-sensible/plugin/sensible.vim
	source ~/.vim/rc/digraphs.vim
endif

endif

"}}}======== Prolog of Miscellaneous Initialization =================/

"{{{======== Settings ===============================================\

"{{{ command Set
function! TrySet(s)
	let l:opt = matchstr(a:s, '^\a*')
	if exists('+' . l:opt)
		execute 'set' a:s
	endif
endfunction
command! -nargs=1 Set call TrySet(<q-args>)
"}}}
"{{{ General Settings
set noautowrite
set background=dark
set backup
set backupcopy=yes
set backupdir=~/.vim/backups
" No Byte Order Mark.
set nobomb
if exists('+breakindent')
	set breakindent
endif
set browsedir=current
set cmdheight=2
set colorcolumn=+2
set completeopt=menuone,preview
set cryptmethod=blowfish
set cursorline
set encoding=utf-8
set fileencodings=utf-8,default
set foldmethod=marker
set formatoptions-=t
set formatoptions+=j
set hidden
set hlsearch
set ignorecase
set lazyredraw
set linebreak
"set matchpairs+=<:>
set maxcombine=6
set nomodeline
set mouse=ar
set mousemodel=popup
set nrformats+=alpha
set number
set omnifunc+=syntaxcomplete#Complete
" That’s `set pastetoggle=^\`, with `^\` being a U+001C FILE SEPARATOR
" (produced by typing Control-Backslash).
" [2014-08-19 11:37 -0700] I’m changing it to `\\\\` (two backslashes),
" because the `<C-\>` was interfering too much with `<C-\><C-N>`.
" [2014-08-22 17:10 -0700] Now I’m changing it to `<Esc>\`, because using
" non-control characters alone is bad in Insert mode.
set pastetoggle=\
set path=.,**
set redrawtime=64
set report=0
" If ruler, showcmd, or both are on, I get problems with the cursor.
" …But Airline also causes the problem somehow, so I might as well use ruler
" and showcmd.
"set ruler " Set by sensible.
if &scrolloff < 2
	set scrolloff=2
endif
set shellcmdflag=-c
if v:version >= 704 || (v:version == 703 && has('patch629'))
	set shiftwidth=0
else
	" Won’t reflect changes to tabstop, but better than nothing.
	let &shiftwidth = &tabstop
endif
set shortmess=I
" That’s `set showbreak=:.:..`, with `:` being a U+2508 BOX DRAWINGS LIGHT
" QUADRUPLE DASH HORIZONTAL and `.` being a U+00A0 NO-BREAK SPACE.
set showbreak=┈ ┈  
" See `set ruler`.
"set showcmd " Set by sensible.
set showfulltag
set showtabline=2
set smartcase
set suffixes+=~,.bak,.swp,.blg,brf,.cb,.ind,.idx,.ilg,.inx,.toc
" I found that the quantity of times I regretted losing my undo history on
" close was less than the quantity of times I wanted to use the start of that
" history as an “anchor” to a “clean” state, and found that I’d gotten lost in
" the undo history and had undone past the clean state.
" [2014-01-21 11:00 -0800] I’ve added mappings to ease such reversion, so I’m
" enabling these now.
" [2014-09-03 13:49 -0700] Note from the future: I’ve barely ever, or maybe
" never, used those mappings….
if exists('+undodir') && exists('+undofile')
	set undodir=~/.vim/undohist
	set undofile
endif
set viminfo+=h
set wildmode=longest:full
set wrapscan

setglobal fileencoding=utf-8

if exists('g:vimrc_settings_only')
	finish
endif
"}}}
"{{{ File class settings

let s:file_classes = ['text', 'code', 'ddfn', 'mesg']

"{{{ Text settings
" Settings for *editing* lightweight markup languages and similar rich-text
" filetypes.
function! ApplyTextSettings()
	setlocal formatoptions+=t
	setlocal spell
	if !&textwidth
		setlocal textwidth=78
	endif
	autocmd Syntax * syntax match vimrcUnicodeCharacterId "\<U+\x\+"
		\ contains=@NoSpell
endfunction
"}}}
"{{{ Code settings
" Settings for filetypes that aren’t English text, where reformatting
" text in ways that would work for English text wouldn’t work.
function! ApplyCodeSettings()
	setlocal formatoptions-=a
	setlocal formatoptions-=t
	setlocal nospell
	if !&textwidth
		setlocal textwidth=78
	endif
endfunction
"}}}
"{{{ Non-message settings
" Settings for everything that isn’t an email or commit message.
function! ApplyNonMessageSettings()
	if !&textwidth
		setlocal textwidth=78
	endif
endfunction
"}}}
"{{{ Message settings
" Settings for *writing* email messages and version-control-system commit
" messages.
function! ApplyMessageSettings()
	setlocal expandtab
	if !&shiftwidth
		setlocal shiftwidth=4
	endif
	setlocal spell
	if !&textwidth
		setlocal textwidth=72
	endif
endfunction
"}}}
"{{{ Read-only settings
" Settings to be applied when &readonly is set.
function! ApplyReadOnlySettings()
	setlocal colorcolumn=0
	setlocal nospell
endfunction
"}}}
"{{{ General settings
" Settings for all files, to be applied after filetype plugins (and the above
" Apply*Settings functions) run.
function! ApplyGeneralSettings()
	if exists('+breakindent') && &breakindent && exists('+showbreak')
		let l:i = &tabstop ? &tabstop : &shiftwidth
		let l:i = ((l:i ? l:i : &softtabstop) / 2) - 1
		let l:i = l:i <= 3 ? l:i : 3
		let &l:showbreak = [' ', '┈ ', '┈  ', ' ┈  '][l:i]
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
endfunction!
"}}}
"{{{ Convenience commands
for s:c in [
\	'Text', 'Code', 'Message', 'NonMessage', 'ReadOnly',
\	'General', 'FileClass'
\ ]
	execute 'command! -bar Apply'
		\ .s:c.'Settings call Apply'.s:c.'Settings()'
endfor
for s:c in ['Text', 'Code', 'Ddfn', 'Mesg']
	execute 'command! -nargs=1 Register'.s:c
		\ .'FileType call RegisterFileTypeInClass(<q-args>, "'
		\ .tolower(s:c).'")'
endfor
"}}}
"{{{ File class functions
"{{{ ApplyFileClassSettings()
function! ApplyFileClassSettings()
	if CurrentFileTypeIsInClass('mesg')
		ApplyMessageSettings
	else
		ApplyNonMessageSettings
	endif

	if CurrentFileTypeIsInClass('text')
		ApplyTextSettings
	endif

	if CurrentFileTypeIsInClass('code')
		ApplyCodeSettings
	endif

	if &readonly
		ApplyReadOnlySettings
	endif

	ApplyGeneralSettings
endfunction
"}}}
"{{{ FmtFileClassFilePath(class)
function! FmtFileClassFilePath(class)
	return $HOME . '/.vim/rc/' . a:class . 'types'
endfunction
"}}}
"{{{ ReadFileClassTypes(class)
function! ReadFileClassTypes(class)
	return readfile(FmtFileClassFilePath(a:class))
endfunction
"}}}
"{{{ WriteFileClassTypes(class, types)
function! WriteFileClassTypes(class, types)
	return writefile(a:types, FmtFileClassFilePath(a:class))
endfunction
"}}}
"{{{ LoadFileClasses()
function! LoadFileClasses()
	for l:c in s:file_classes
		let s:{l:c}Types = ReadFileClassTypes(l:c)
		let s:{l:c}TypesChanged = 0
	endfor
endfunction
"}}}
"{{{ SaveFileClasses()
function! SaveFileClasses()
	for l:c in s:file_classes
		if s:{l:c}TypesChanged
			call WriteFileClassTypes(l:c, s:{l:c}Types)
		endif
	endfor
endfunction
"}}}
"{{{ GetFileClassTypes(class)
function! GetFileClassTypes(class)
	return s:{a:class}Types
endfunction
"}}}
"{{{ RegisterFileTypeInClass(type, class)
function! RegisterFileTypeInClass(type, class)
	call add(s:{a:class}Types, a:type)
	let s:{a:class}TypesChanged = 1
endfunction
"}}}
"{{{ FileTypeIsInClass(type, class)
function! FileTypeIsInClass(type, class)
	return IsInList(GetFileClassTypes(a:class), a:type)
endfunction
"}}}
"{{{ CurrentFileTypeIsInClass(class)
function! CurrentFileTypeIsInClass(class)
	return FileTypeIsInClass(&l:filetype, a:class)
endfunction
"}}}
"}}}
"{{{ Autocommands
autocmd VimLeave * call SaveFileClasses()
autocmd FileType * ApplyFileClassSettings
call LoadFileClasses()
"}}}

"}}} File class settings

"}}}======== Settings ===============================================/

"{{{======== Miscellaneous Variables ================================\

let g:unit_prefixes = split('yotta zetta exa peta tera giga mega kilo hecto deca deci centi milli micro nano pico femto atto zepto yocto', ' ')
let g:units_of_measure = split('metre meter gram second ampere kelvin mole candela radian steradian hertz newton pascal joule watt coulomb volt farad ohm siemens weber tesla henry degree lumen lux becquerel gray sievert katal byte bit octet trit nibble semioctet quartet seminibble', ' ')

"}}}======== Miscellaneous Variables ================================/

"{{{======== General Functions ======================================\

"{{{ command Assert, IAssert, RunInteractiveTests
command! -nargs=1 Assert
	\  if !(<args>)
	\|	throw 'assertion failed: ' . <q-args>
	\| endif

Assert 1

let s:interactiveTestCaseList = []
command! -nargs=1 IAssert call add(s:interactiveTestCaseList, <q-args>)

command! -bar RunInteractiveTests call RunInteractiveTests()
function! RunInteractiveTests()
	for l:t in s:interactiveTestCaseList
		execute 'Assert' l:t
	endfor
endfunction
"}}}
"{{{ Filter(x, s)
function! Filter(x, s)
	return filter(copy(a:x), a:s)
endfunction

Assert Filter([1,2,3], 'v:val % 2 == 0') == filter([1,2,3], 'v:val % 2 == 0')
"}}}
"{{{ Map(x, s)
function! Map(x, s)
	return map(copy(a:x), a:s)
endfunction

Assert Map([1,2,3], 'v:val * 2') == map([1,2,3], 'v:val * 2')
"}}}
"{{{ NCmp(x, y)
" Returns 1 if x > y, -1 if x < y, and 0 if neither (i.e., if x = y).
function! NCmp(x, y)
	return +a:x < +a:y ? -1 : +a:x > +a:y
endfunction

Assert NCmp(0, 0) == 0
Assert NCmp(1, 0) == 1
Assert NCmp(0, 1) == -1
Assert NCmp(100, 100) == 0
Assert NCmp(100, -100) == 1
Assert NCmp(-100, 100) == -1
Assert NCmp('0', '0') == 0
Assert NCmp('1', '0') == 1
Assert NCmp('0', '1') == -1
Assert NCmp('100', '100') == 0
Assert NCmp('100', '-100') == 1
Assert NCmp('-100', '100') == -1
Assert NCmp('x', 'y') == 0
"}}}
"{{{ NSort(list)
" Sorts `list` (in-place), sorting the elements as numbers rather than
" strings. Returns the sorted `list`.
function! NSort(list)
	return sort(a:list, 'NCmp')
endfunction

Assert NSort([1, 2, 3]) == [1, 2, 3]
Assert NSort([10, 111, 12]) == [10, 12, 111]
"}}}
"{{{ IsInList(list, x)
" If `x` is in `list`, returns 1; otherwise, returns 0.
function! IsInList(list, x)
	return index(a:list, a:x) != -1
endfunction
"}}}
"{{{ StripDupElems(list)
" Returns a shallow copy of `list`, sans any elements that are present
" elsewhere in the list.
function! StripDupElems(list)
	let l:i = 0
	let l:l = len(a:list)
	let l:r = []
	while l:i < l:l
		if index(a:list, a:list[l:i]) == l:i
			call add(l:r, a:list[l:i])
		endif
		let l:i += 1
	endwhile
	return l:r
endfunction

Assert StripDupElems([1,2,3,2,1]) == [1,2,3]
Assert StripDupElems([3,2,1,1,2,3]) == [3,2,1]
"}}}
"{{{ NrToChar(n, utf8)
function! NrToChar(n, utf8)
	if v:version >= 704
		return nr2char(a:n, a:utf8)
	else
		return nr2char(a:n)
	endif
endfunction

Assert NrToChar(1, 1) ==# ''
Assert NrToChar(127, 1) ==# ''
"}}}
"{{{ ShellEsc(string)
" As shellescape(), but does not add backslashes before newlines.
" In zsh, bash, and dash, a backslash before a newline, in a single-quoted
" string, results in a literal backslash and a literal newline.
function! ShellEsc(string)
	return substitute(shellescape(a:string), '\\\n', '\n', 'g')
endfunction
"}}}
"{{{ GetBufferText()
function! GetBufferText()
	return join(getline(1, '$'), "\n")
endfunction
"}}}
"{{{ GetBufferTextLen()
function! GetBufferTextLen()
	return strlen(GetBufferText())
endfunction
"}}}
"{{{ GetSelection()
" Returns the current Visual selection.
" See <http://stackoverflow.com/a/6271254/2945834>.
if 0
function! GetSelection()
	let [l:line1, l:col1] = getpos("'<")[1:2]
	let [l:line2, l:col2] = getpos("'>")[1:2]
	let l:lines = getline(l:line1, l:line2)
	let l:lines[-1] = l:lines[-1][: l:col2 -
		\ (&selection == 'inclusive' ? 1 : 2)]
	let l:lines[0] = l:lines[0][l:col1 - 1 :]
	return join(l:lines, "\n")
endfunction
else
function! GetSelection()
	let l:r = GetReg('v')
	try
		normal! gv"vy
		return @v
	finally
		call PutReg(l:r)
	endtry
endfunction
endif
"}}}
"{{{ FindUnusedChar(string)
" Returns the first non-null UTF-8 character that is not used in `string`.
function! FindUnusedChar(string)
	let l:c = 1
	while stridx(a:string, NrToChar(l:c, 1)) != -1
		let l:c += 1
	endwhile
	return NrToChar(l:c, 1)
endfunction

Assert FindUnusedChar('') ==# ''
Assert FindUnusedChar('a') ==# ''
Assert FindUnusedChar('') ==# ''
Assert FindUnusedChar('') ==# ''
Assert FindUnusedChar('') ==# ''
Assert FindUnusedChar('') ==# ''
"}}}
"{{{ SSSplit(string[, noword])
" Split `string` on its first character, like :substitute’s separator.
" If `string`’s first character is a word character (alphanumeric character or
" low line), then:
"   - if `noword` is a string, it will be thrown; or
"   - if `noword` is truthy, a generic error message will be thrown.
function! SSSplit(string, ...)
	if a:0 && a:string[0] =~ '\w'
		if type(a:1) == type('')
			throw a:1
		elseif a:1
			throw 'SSSplit(string): first character of `string` may not be a word character.'
		endif
	endif
	return split(a:string[1:], '\V' . a:string[0], 1)
endfunction

Assert SSSplit('') ==# ['']
Assert SSSplit(' ') ==# ['']
Assert SSSplit('/a/b') ==# ['a', 'b']
Assert SSSplit(' x y z ') ==# ['x', 'y', 'z', '']
"}}}
"{{{ WrapSubLists(list, n)
" Returns a copy of `list` with each group of `n` elements wrapped in a list.
" E.g.: `WrapSubLists([1, 2, 3, 4, 5, 6], 2)` = [[1, 2], [3, 4], [5, 6]]
function! WrapSubLists(list, n)
	if len(a:list) % a:n
		throw 'WrapSubLists(list, n): `list` must be evenly divisible by `n`.'
	endif
	let [l:r, l:i] = [[], 0]
	while i < len(a:list)
		call add(l:r, a:list[l:i : (l:i + a:n - 1)])
		let l:i += a:n
	endwhile
	return l:r
endfunction

Assert WrapSubLists(range(1, 6), 2) ==# [[1, 2], [3, 4], [5, 6]]
Assert WrapSubLists(range(1, 6), 3) ==# [[1, 2, 3], [4, 5, 6]]
"}}}
"{{{ SetReg(r, x); SetUNReg(x); GetReg(r); PutReg(x)
" Set register, preserving register type.
function! SetReg(r, x)
	call setreg(a:r, a:x, getregtype(a:r))
endfunction
" Set unnamed register.
function! SetUNReg(x)
	call SetReg('', a:x)
endfunction
" Get register and type, as [name, value, type].
function! GetReg(r)
	return [a:r, getreg(a:r, 1), getregtype(a:r)]
endfunction
" Set register and type (takes output of GetReg).
function! PutReg(x)
	let [l:name, l:value, l:type] = a:x
	call setreg(l:name, l:value, l:type)
endfunction
"}}}
"{{{ SwapStrings(string, swapList)
" For all pairs of strings (x, y) in `swapList`, swaps all instances of `x` in
" `string` for `y` and all instances of `y` in `string` for `x`.
" Returns the altered version of `string`.
" Does not mutate `string` in-place.
" E.g.:
"   `SwapStrings('abcdefabc', ['a', 'b', 'def', 'x', 'x', 'y'])` = 'bacxbac'
function! SwapStrings(string, swapList)
	if len(a:swapList) % 2
		throw 'SwapStrings(string, swapList): `len(swapList)` must be even, but `swapList` is `'
			\ . string(a:swapList) . '`.'
	endif
	let [l:s, l:phase2] = [a:string, []]
	for [l:x, l:y] in WrapSubLists(a:swapList, 2)
		let l:c = FindUnusedChar(l:s . l:x . l:y)
		let l:s = substitute(l:s, l:x, l:c, 'g')
		call add(l:phase2, [l:c, l:y])
		let l:c = FindUnusedChar(l:s . l:x . l:y)
		let l:s = substitute(l:s, l:y, l:c, 'g')
		call add(l:phase2, [l:c, l:x])
	endfor
	for [l:from, l:to] in l:phase2
		let l:s = substitute(l:s, l:from, l:to, 'g')
	endfor
	return l:s
endfunction

Assert SwapStrings('abcdefabc', ['a', 'b', 'def', 'x', 'x', 'y']) ==# 'bacxbac'
Assert SwapStrings('abc "foo ''bar'' foo" abc', SSSplit(' '' "'))
	\ ==# 'abc ''foo "bar" foo'' abc'
"}}}
"{{{ SIPrefix(n)
function! SIPrefix(n)
	let l:m = 8
	while a:n < pow(1000, l:m) && l:m >= 1
		let l:m -= 1
	endwhile
	return [a:n / pow(1000, l:m), 'kMGTPEZY'[l:m-1]]
endfunction

Assert SIPrefix(16) == [16.0, '']
Assert SIPrefix(1024) == [1.024, 'k']
Assert SIPrefix(1048576) == [1.048576, 'M']
"}}}
"{{{ BinaryPrefix(n)
function! BinaryPrefix(n)
	let l:m = 8
	while a:n < pow(1024, l:m) && l:m >= 1
		let l:m -= 1
	endwhile
	return [a:n / pow(1024, l:m), 'KMGTPEZY'[l:m-1] . (l:m ? 'i' : '')]
endfunction

Assert BinaryPrefix(10) ==# [10.0, '']
Assert BinaryPrefix(10000) ==# [9.765625, 'Ki']
Assert BinaryPrefix(1.0e7) ==# [1.0e7/1048576, 'Mi']
"}}}
"{{{ FmtBytes(n[, prefixType])
function! FmtBytes(n, ...)
	let Prefix = function((!a:0 || a:1 !=? 'si')
		\ ? 'BinaryPrefix' : 'SIPrefix')
	let [l:n, l:p] = Prefix(a:n)
	return printf('%g %sB', l:n, l:p)
endfunction
"}}}
"{{{ InputLocked(expr)
function! InputLocked(expr)
	call inputsave()
	let l:r = eval(a:expr)
	call inputrestore()
	return l:r
endfunction
"}}}
"{{{ ReadChar()
function! ReadChar()
	return nr2char(getchar())
endfunction
"}}}
"{{{ PromptChar(prompt)
function! PromptChar(prompt)
	call inputsave()
	echon a:prompt
	let l:r = ReadChar()
	call inputrestore()
	return l:r
endfunction
"}}}
"{{{ PromptLine(prompt[, text[, completion]])
" Same as input(), but wrapped in inputsave() and inputrestore(), so it works
" in mappings.
" `completion` can also be 'secret', in which case inputsecret() will be used
" rather than input().
function! PromptLine(prompt, ...)
	call inputsave()
	if a:0 == 0
		let l:r = input(a:prompt)
	elseif a:0 == 1
		let l:r = input(a:prompt, a:1)
	elseif a:0 == 2
		if a:2 == 'secret'
			let l:r = inputsecret(a:prompt, a:1)
		else
			let l:r = input(a:prompt, a:1, a:2)
		endif
	else
		throw 'PromptLine(prompt[, text[, completion]]): takes 1..3 arguments; given ' . (a:0 + 1)
	endif
	call inputrestore()
	return l:r
endfunction
"}}}
"{{{ PromptCharOrLine(prompt[, text[, completion]])
" Opens a prompt. If the user enters a character that is not <NL> or <CR>,
" returns that character. If the user enters <NL> or <CR>, this function will
" behave like PromptLine().
function! PromptCharOrLine(prompt, ...)
	call inputsave()
	let l:r = PromptChar(a:prompt)
	if l:r == "\<NL>" || l:r == "\<CR>"
		let l:r = call('PromptLine', [''] + a:000)
	endif
	call inputrestore()
	return l:r
endfunction
"}}}
"{{{ ToggleOpt(opt[, on, off])
function! ToggleOpt(opt, ...)
	if a:0 == 0
		execute 'setlocal' (eval('&'.a:opt) == a:on ? 'no' : '').a:opt
	elseif a:0 == 2
		execute 'setlocal' a:opt.'='
			\ . (eval('&'.a:opt) == a:on ? a:1 : a:2)
	else
		throw 'ToggleOpt(opt[, on, off]): takes 1 or 3 arguments; given ' . (a:0 + 1)
	endif
endfunction
"}}}
"{{{ DoubleBackslashes(string)
function! DoubleBackslashes(string)
	return escape(a:string, '\')
endfunction

Assert DoubleBackslashes('') == ''
Assert DoubleBackslashes('abc') == 'abc'
Assert DoubleBackslashes('a\\z') == 'a\\\\z'
"}}}
"{{{ VerbatimPattern(string)
function! VerbatimPattern(string)
	return '\V' . DoubleBackslashes(a:string)
endfunction

Assert VerbatimPattern('') == '\V'
Assert VerbatimPattern('abc') == '\Vabc'
Assert VerbatimPattern('^\a\_$') == '\V^\\a\\_$'
"}}}
"{{{ VPut(x)
function! VPut(x)
	if type(a:x) == type('')
		let l:x = '"' . substitute(substitute(escape(string(a:x)[1:-2],
			\ '"\'), '\r', '\\r', 'g'), '\n', '\\n', 'g') . '"'
	else
		let l:x = string(a:x)
	endif
	execute 'silent normal! gv"=' l:x "\<CR>P"
endfunction
"}}}
"{{{ VPutExpr(x)
function! VPutExpr(x)
	execute 'silent normal! gv"=' a:x "\<CR>P"
endfunction
"}}}
"{{{ Matches(string, pattern)
" Returns a list of all matches of `pattern` in `string`.
function! Matches(string, pattern)
	if a:pattern == ''
		throw 'pattern must not be the empty string'
	endif
	let l:i = 0
	let l:r = []
	while 1
		let l:s = matchstr(a:string, a:pattern, l:i)
		let l:i = match(a:string, a:pattern, l:i)
		if l:i != -1
			call add(l:r, l:s)
			let l:l = strlen(l:s)
			let l:i += l:l ? l:l : 1
		else
			break
		endif
	endwhile
	return l:r
endfunction

Assert Matches('', '.*') == ['']
Assert Matches('abc', 'x') == []
Assert Matches('abc', '.') == ['a', 'b', 'c']
Assert Matches('abc foo xyz', '\<\a\+\>') == ['abc', 'foo', 'xyz']
Assert Matches('(abc) (foo) (xyz)', '(\zs\a\+\ze)') == ['abc', 'foo', 'xyz']
"}}}
"{{{ MatchesSansEmpties(string, pattern)
" Returns a list of all matches of `pattern` in `string`, sans matches that
" are the empty string.
function! MatchesSansEmpties(string, pattern)
	return filter(Matches(a:string, a:pattern), 'v:val != ""')
endfunction
"}}}
"{{{ MatchesSansDups(string, pattern)
" Returns a list of all matches of `pattern` in `string`, sans matches that
" are duplicates of earlier matches.
function! MatchesSansDups(string, pattern)
	return StripDupElems(Matches(a:string, a:pattern))
endfunction
"}}}
"{{{ MatchesSansEmptiesAndDups(string, pattern)
" Returns a list of all matches of `pattern` in `string`, sans matches that
" (a) are the empty string, or (b) are duplicates of earlier matches.
function! MatchesSansEmptiesAndDups(string, pattern)
	return filter(MatchesSansDups(a:string, a:pattern), 'v:val != ""')
endfunction
"}}}
"{{{ MatchesInBuffer(pattern)
" Returns a list of all matches of `pattern` in the current buffer.
function! MatchesInBuffer(pattern)
	return Matches(GetBufferText(), a:pattern)
endfunction
"}}}
"{{{ MatchesInBufferSansEmpties(pattern)
" Returns a list of all matches of `pattern` in the current buffer, sans
" matches that are the empty string.
function! MatchesInBufferSansEmpties(pattern)
	return MatchesSansEmpties(GetBufferText(), a:pattern)
endfunction
"}}}
"{{{ MatchesInBufferSansDups(pattern)
" Returns a list of all matches of `pattern` in the current buffer, sans
" matches that are duplicates of earlier matches.
function! MatchesInBufferSansDups(pattern)
	return MatchesSansDups(GetBufferText(), a:pattern)
endfunction
"}}}
"{{{ MatchesInBufferSansEmptiesAndDups(pattern)
" Returns a list of all matches of `pattern` in the current buffer, sans
" matches that (a) are the empty string, or (b) are duplicates of earlier
" matches.
function! MatchesInBufferSansEmptiesAndDups(pattern)
	return MatchesSansEmptiesAndDups(GetBufferText(), a:pattern)
endfunction
"}}}
"{{{ SHA256(string)
function! SHA256(string)
	return exists('*sha256')
		\ ? sha256(a:string)
		\ : matchstr(system('sha256sum =(<<<'
			\ . ShellEsc(a:string) . ')'), '\S\+')
endfunction
"}}}
"{{{ MD5(string)
function! MD5(string)
	return matchstr(
		\ system('md5sum =(<<<' . ShellEsc(a:string) . ')'), '\S\+')
endfunction
"}}}
"{{{ Hash(string)
function! Hash(string)
	return exists('*sha256') ? sha256(a:string) : MD5(a:string)
endfunction
"}}}
"{{{ Qalc(expr)
function! Qalc(expr)
	return substitute(system('qalc ' . ShellEsc(a:expr)),
		\ '.* = \(.*\)\n', '\1', '')
endfunction
"}}}

"}}}======== General Functions ======================================/

"{{{======== Mappings and Commands ==================================\

"{{{ Wrapper commands for General Functions
command! -nargs=1 -range VPut call VPut(<args>)
command! -nargs=1 -range VPutExpr call VPutExpr(<q-args>)
command! -nargs=1 Qalc call Qalc(<q-args>)
"}}}
"{{{ Map(modes, key); AMap(key)
function! Map(modes, key)
	if a:modes == '*'
		execute 'map' a:key
		execute 'map!' a:key
		return
	endif
	for m in a:modes
		execute m.'map' a:key
	endfor
endfunction
function! AMap(key)
	call Map('*', a:key)
endfunction
"}}}
"{{{ Motion keys
"{{{ Raw escape sequence interpretation
" I know I should do this in terminfo, but terminfo is… arcaner.
call AMap('<Esc>OA <Up>')
call AMap('<Esc>OB <Down>')
call AMap('<Esc>OC <Right>')
call AMap('<Esc>OD <Left>')
call AMap('<Esc>[A <C-Up>')
call AMap('<Esc>[B <C-Down>')
call AMap('<Esc>[C <C-Right>')
call AMap('<Esc>[D <C-Left>')
call AMap('<Esc><Up> <A-Up>')
call AMap('<Esc><Down> <A-Down>')
call AMap('<Esc><Right> <A-Right>')
call AMap('<Esc><Left> <A-Left>')
call AMap('<Esc>[1;9A <A-Up>')
call AMap('<Esc>[1;9B <A-Down>')
call AMap('<Esc>[1;9C <A-Right>')
call AMap('<Esc>[1;9D <A-Left>')
call AMap('<Esc>[1;2H <S-Home>')
call AMap('<Esc>[1;2F <S-End>')
call AMap('<Esc>[1;9H <A-Home>')
call AMap('<Esc>[1;9F <A-End>')
"}}}
"{{{ `<S-Left/Right>` — scroll left/right by characters
noremap <S-Left> zh
noremap <S-Right> zl
inoremap <S-Left> <C-O>zh
inoremap <S-Right> <C-O>zl
"}}}
"{{{ `<S-C-Left/Right>` — scroll left/right by half-screens
noremap <S-C-Left> zH
noremap <S-C-Right> zL
inoremap <S-C-Left> <C-O>zH
inoremap <S-C-Right> <C-O>zL
"}}}
"{{{ `<C-Left/Right>` — move to word boundary (punctuation)
noremap <silent> <C-Right> :CRight<CR>
noremap <silent> <C-Left> :CLeft<CR>
inoremap <C-Right> <Esc>ea
inoremap <C-Left> <Esc>bi
vnoremap <silent> <C-Right> :VCRight<CR>
vnoremap <silent> <C-Left> :VCLeft<CR>
"}}}
"{{{ `<A-Left/Right>` — move to WORD boundary (whitespace)
noremap <silent> <A-Right> :ARight<CR>
noremap <silent> <A-Left> :ALeft<CR>
inoremap <A-Right> <Esc>Ea
inoremap <A-Left> <Esc>Bi
vnoremap <silent> <A-Right> :VARight<CR>
vnoremap <silent> <A-Left> :VALeft<CR>
"}}}
"{{{ `<S-Up/Down>` — scroll up/down by lines
noremap <S-Up> <C-Y>
noremap <S-Down> <C-E>
inoremap <S-Up> <C-O><C-Y>
inoremap <S-Down> <C-O><C-E>
"}}}
"{{{ `<C-Up/Down>` — scroll up/down by half-screens
noremap <C-Up> <C-U>
noremap <C-Down> <C-D>
inoremap <C-Up> <C-O><C-U>
inoremap <C-Down> <C-O><C-D>
"}}}
"{{{ `<A-Up/Down>` — move up/down in terms of *display* lines
noremap <A-Up> gk
noremap <A-Down> gj
inoremap <A-Up> <C-O>gk
inoremap <A-Down> <C-O>gj
"}}}
"{{{ `<S-Home/End>` — move to start/end of line (excluding spaces)
noremap <S-Home> ^
noremap <S-End> g_
inoremap <S-Home> <C-O>^
inoremap <S-End> <C-O>g_
"}}}
"{{{ `<C-Home/End>` — move to start/end of buffer
" This is the default behavior; this section is here only for documentation.
"}}}
"{{{ `<A-Home/End>` — move to start/end of *display* line
noremap <A-Home> g0
noremap <A-End> g$
inoremap <A-Home> <C-O>g0
inoremap <A-End> <C-O>g$
"}}}
"{{{ `<Leader><Up/Down/Left/Right>` — move without beeping at edges
noremap <silent> <Leader><Up> :Up<CR>
noremap <silent> <Leader><Down> :Down<CR>
noremap <silent> <Leader><Right> :Right<CR>
noremap <silent> <Leader><Left> :Left<CR>
vnoremap <silent> <Leader><Up> :VUp<CR>
vnoremap <silent> <Leader><Down> :VDown<CR>
vnoremap <silent> <Leader><Right> :VRight<CR>
vnoremap <silent> <Leader><Left> :VLeft<CR>
"}}}
"{{{ Command-Line mappings
"cnoremap <C-A> <Home>
"}}}
"{{{ Commands for cardinal movement that won’t beep at edges
"{{{ Normal
command! -bar Up     if line('.') != 1          | Normal k | endif
command! -bar Down   if line('.') != line('$')  | Normal j | endif
command! -bar Right  if  col('.') != col('$')-1 | Normal l | endif
command! -bar Left   if  col('.') != 1          | Normal h | endif
"}}}
"{{{ Control-*
command! -bar CRight  Normal e | Right
command! -bar CLeft   Normal b | Left
"}}}
"{{{ Alt-*
command! -bar ARight  Normal E | Right
command! -bar ALeft   Normal B | Left
"}}}
"{{{ Visual mode
command! -bar -range VUp      Normal gv | Up
command! -bar -range VDown    Normal gv | Down
command! -bar -range VRight   Normal gv | Right
command! -bar -range VLeft    Normal gv | Left
command! -bar -range VCRight  Normal gv | CRight
command! -bar -range VCLeft   Normal gv | CLeft
command! -bar -range VARight  Normal gv | ARight
command! -bar -range VALeft   Normal gv | ALeft
"}}}
"}}}
"}}} Motion keys
"{{{ Delete key
imap <Esc>[3;5~ <C-Del>
imap <Esc>[3;6~ <C-S-Del>
inoremap <C-Del> <C-O>de<Del>
inoremap <C-S-Del> <C-O>dE<Del>
"}}}
"{{{ MISCELLANEOUS
" Like :normal, but doesn’t eat bars.
command! -nargs=1 -bar Normal execute 'normal' <q-args>

"{{{ Make `ZZ` and `ZQ` ask for confirmation.
" They’re just too dangerous otherwise.

function! ZZ()
	if PromptChar('Save and close? Type ‘Y’ to confirm or anything else to cancel…')
			\ ==# 'Y'
		xit
	else
		echo 'ZZ (save and close) canceled.'
	endif
endfunction
function! ZQ()
	if PromptChar('Close without saving? Type ‘Y’ to confirm or anything else to cancel…')
			\ ==# 'Y'
		quit!
	else
		echo 'ZQ (close without saving) canceled.'
	endif
endfunction

command! -bar ZZ call ZZ()
command! -bar ZQ call ZQ()

noremap <silent> ZZ :ZZ<CR>
noremap <silent> ZQ :ZQ<CR>
"}}}

"{{{ Make <C-W><C-C> cancel the command, not close the window.
" The documentation claims that it should work thus anyway, but it doesn’t for
" me.
"
" According to a bisection of this vimrc, the fault lies with the “Display
" Customization” → “Color line numbers differently in and out of Insert mode”
" section.
noremap <silent> <C-W><C-C> :<CR>
"}}}

" Buffers.
noremap <silent> gb :bnext<CR>
noremap <silent> gB :bprevious<CR>

" Cf. `gp`.
vnoremap gy y`>

" With this, if I use a leader-prefixed mapping that turns out to not exist, it
" gets dumped into a command line, rather than being interpreted sans leader.
noremap <Leader> :

"map <Space> <Leader>
imap <Esc> <C-O><Leader>

noremap <C-H> :tab help<Space>
inoremap <C-H> <C-C>:tab help<Space>

imap <C-L> <C-C><C-L>gi

noremap Q gq

vnoremap <A-<> <gv
vnoremap <A->> >gv

" Matches 'pastetoggle'.
inoremap <silent> <Esc>\ <C-O>:set invpaste<CR>

command! -nargs=1 Gcount
	\  let s:n = 0
	\| global<args>let s:n += 1
	\| echo s:n
	\| unlet s:n
"}}}
"{{{ `<Leader><[iIaAoO]>` — Insertion macro machinery
"   - `<Leader>i` inserts before the cursor.
"   - `<Leader>a` inserts after the cursor.
"   - `<Leader>I` inserts at the start of the current line.
"   - `<Leader>A` inserts at the end of the current line.
"   - `<Leader>o` inserts on a new line below the cursor.
"   - `<Leader>O` inserts on a new line above the cursor.

for s:m in split('iIaAoO', '\zs')
	execute 'noremap <silent> <Leader>' . s:m
		\ ':call LeaderInsert(' string(s:m) ')<CR>'
endfor

let [s:leaderInserts, s:leaderInsertKeys] = [{}, []]

function! LeaderInsert(imode)
	if a:imode !~? '^[iao]$'
		throw 'LeaderInsert(imode, key): `imode` must be in ''iIaAoO'', but it is ' . string(a:imode)
	endif
	let [l:s, l:c] = ['', '']
	echon '<Leader>' a:imode '… '
	while 1
		let l:c = ReadChar()
		if l:c == "\<C-C>"
			return
		elseif l:c == "\<NL>" || l:c == "\<CR>"
			let l:s = PromptLine('', '',
				\ 'custom,LeaderInsertCompleter')
			break
		endif
		let l:s .= exists('mapleader') && maparg(l:c) == mapleader
			\ ? mapleader : l:c
		if has_key(s:leaderInserts, l:s)
			execute 'normal!' a:imode . "\<C-R>\<C-R>=InputLocked("
				\ string(s:leaderInserts[l:s]) ")\<CR>"
			return
		endif
		if match(s:leaderInsertKeys,
				\ '^' . VerbatimPattern(l:s)) == -1
			echoerr 'leader-insert macro' string(l:s) 'not found'
			return
		endif
	endwhile
	throw 'how did I get here?'
endfunction

function! LIGetInput(expr)
	call inputsave()
	return string(PromptCharOrLine('Bad hack. Bad.'))
	let l:r = InputLocked(a:expr)
	call inputrestore()
	return l:r
endfunction

function! LeaderInsertCompleter(...)
	return join(s:leaderInsertKeys, "\n")
endfunction

function! DfnInsertMacro(key, expr)
	let s:leaderInserts[a:key] = a:expr
	call add(s:leaderInsertKeys, a:key)
endfunction

"}}}zo
"{{{ `<Leader>it…` — Insert Timestamp
"  `<Leader>itZP` — insert timestamp in timezone Z to precision P.
"  Z can be…
"    `u`, for UTC;
"    `l`, for local time; or
"    `z`, to open a prompt at which one can enter a timezone to use.
"  Z can also be upper-case. If Z is upper-case, the timezone will not
"    be included in the inserted timestamp.
"  P can be…
"    `s`, for seconds;
"    `m`, for minutes;
"    `h`, for hours;
"    `d`, for days;
"    `n`, for months;
"    `y`, for years;
"    `z`, to insert only the timezone’s offset from UTC;
"    `Z`, to insert only the timezone’s abbreviated name; or
"    `x`, to open a prompt at which one can enter a strftime format string to
"         use.
"  P can also be `S`, `M`, `H`, `D`, `N`, or `Y`; these function like their
"    lower-case equivalents, except that the inserted timestamp will be
"    *from*, rather than *to*, the specified precision.
"  Examples (with the local time being 2014-12-31 23:45:55 -0200):
"      `<Leader>itus` → ‘2015-01-01 01:45:55 UTC’
"      `<Leader>itlm` → ‘2014-12-31 23:45 -0200’
"      `<Leader>itlH` → ‘23:45:55 -0200’
"      `<Leader>itUy` → ‘2015’
"      `<Leader>itlz` → ‘-0200’
function! DfnInsertTimestampKey(key, fmt)
	let l:fmt = a:fmt =~ '%' ? shellescape(a:fmt) : a:fmt
	function s:m(key, expr)
		let l:x = 'substitute('.a:expr.', ''\n$'', '''', '''')'
		"execute 'noremap <silent> <Leader>it' . a:key
		"	\ '"=' . l:x . '<CR>P:Right<CR>'
		"execute 'inoremap <silent> <Esc>it' . a:key
		"	\ '<C-R><C-R>=' . l:x . '<CR>'
		call DfnInsertMacro('t'.a:key, l:x)
	endfunction
	call s:m('u'.a:key, 'system(''date -u ''.ShellEsc(''+''.'.l:fmt.'.'' %Z''))')
	call s:m('l'.a:key, 'strftime('.l:fmt.'.'' %z'')')
	call s:m('z'.a:key, 'system("TZ=".ShellEsc(PromptLine("Timezone: "))." date ".ShellEsc("+".'.l:fmt.'." %z"))')
	call s:m('U'.a:key, 'system("date -u ".ShellEsc("+".'.l:fmt.'))')
	call s:m('L'.a:key, 'strftime('.l:fmt.')')
	call s:m('Z'.a:key, 'system("TZ=".ShellEsc(PromptLine("Timezone: "))." date ".ShellEsc("+".'.l:fmt.'))')
	delfunction s:m
endfunction
for [key, fmt] in [
\	['s', '%F %T'], ['m', '%F %H:%M'], ['h', '%F %H'],
\	['d', '%F'], ['n', '%Y-%m'], ['y', '%Y'],
\	['S', '%S'], ['M', '%M:%S'], ['H', '%T'],
\	['D', '%d %T'], ['N', '%m-%d %T'], ['Y', '%F %T'],
\	['z', '%z'], ['Z', '%Z'],
\	['x', 'PromptLine("strftime format string: ")']
\]
	call DfnInsertTimestampKey(key, fmt)
endfor
"}}}
"{{{ `<Leader>i.n` — Insert Repeatedly, N times
call DfnInsertMacro('.n', 'GetInsertRepeatedlyNTimesString()')
function! GetInsertRepeatedlyNTimesString()
	let l:s = PromptLine('String to repeatedly insert: ')
	let l:n = PromptLine('Repetition quantity: ')
	return repeat(l:s, l:n)
endfunction
"}}}
"{{{ `<Leader>i.c` — Insert Repeatedly, to Column
call DfnInsertMacro('.c', 'GetInsertRepeatedlyToColumnString()')
function! GetInsertRepeatedlyToColumnString()
	let l:s = PromptLine('String to repeatedly insert: ')
	let l:col = PromptLine('Column to insert to: ')
	let l:n = l:col - col('.')
	let l:s = repeat(l:s, l:n+1)
	if l:n > 0 || l:s == ''
		return l:s
	elseif l:n < 0
		echoerr 'you are already past column' l:col
	else
		echoerr 'you are already at column' l:col
	endif
	return ''
endfunction
"}}}
"{{{ `<Leader>i\<…>` — Insert Miscellaneous

" Elision marker
call DfnInsertMacro('\Em', "'[…]'")

"}}}
"{{{ `<Leader>xs` — Exchange Strings
vnoremap <silent> <Leader>xs :VPut SwapStrings(GetSelection(), SSSplit(PromptLine('Pairs of strings to swap (first char is sep, like `:s`):')))<CR>
"}}}
"{{{ `<Leader>!c`, `{Visual}<Leader>!c` — Calculate
noremap <Leader>!c :Qalc<Space>

" TODO: “crimp” the selection so that it doesn’t include leading whitespace,
" so that indentation is preserved.
vnoremap <silent> <Leader>!c :VPut Qalc(GetSelection())<CR>
"}}}
"{{{ TwiddleCase(string); `{Visual}~`
function! TwiddleCase(string)
	if a:string ==# toupper(a:string)
		let l:r = tolower(a:string)
	elseif a:string ==# tolower(a:string)
		let l:r = substitute(a:string, '\v<\w+>', '\u&', 'g')
	else
		let l:r = toupper(a:string)
	endif
	return l:r
endfunction

vnoremap <silent> ~ :VPut TwiddleCase(GetSelection())<CR>
"}}}
"{{{ `<Leader>s…` — Set options
noremap <Leader>sl[ :setlocal<Space>
noremap <Leader>sl] :setlocal no
noremap <Leader>sl\ :setlocal inv
noremap <Leader>sg[ :setglobal<Space>
noremap <Leader>sg] :setglobal no
noremap <Leader>sg\ :setglobal inv
noremap <Leader>sb[ :set<Space>
noremap <Leader>sb] :set no
noremap <Leader>sb\ :set inv

" E.g., `DfnOptKeyB foo` runs:
"	noremap <Leader>sfoo[ :set foo
"	noremap <Leader>sfoo] :set nofoo
"	noremap <Leader>sfoo\ :set invfoo
function! DfnOptKeyA(opt, on, off)
	execute 'noremap <Leader>s'.a:opt.'[ :setlocal' a:opt.'='.a:on.'<CR>'
	execute 'noremap <Leader>s'.a:opt.'] :setlocal' a:opt.'='.a:off.'<CR>'
	execute 'noremap <Leader>s'.a:opt."\ :call ToggleOpt('".a:opt."',"
		\ a:on ',' a:off ')<CR>'
endfunction
command! -nargs=+ DfnOptKeyA call DfnOptKeyA(<f-args>)
function! DfnOptKeyB(opt)
	execute 'noremap <Leader>s'.a:opt.'[ :setlocal' a:opt.'<CR>'
	execute 'noremap <Leader>s'.a:opt.'] :setlocal no'.a:opt.'<CR>'
	execute 'noremap <Leader>s'.a:opt.'\ :setlocal inv'.a:opt.'<CR>'
endfunction
command! -nargs=1 DfnOptKeyB call DfnOptKeyB(<f-args>)

DfnOptKeyA cole 2 0
DfnOptKeyB ro
DfnOptKeyB spell
DfnOptKeyB ve
"}}}
"{{{ Validation

" Validate Spelling
noremap <silent> <Leader>vs :setlocal invspell<CR>

" Validate syntaX
noremap <silent> <Leader>vx :SyntasticReset<CR>:SyntasticCheck<CR>

" Validate Whitespace
noremap <silent> <Leader>vw :AirlineToggleWhitespace<CR>

"}}}
"{{{ Browsing

" Browse Buffers
noremap <silent> <Leader>bb :buffers<CR>

" Browse Files
noremap <silent> <Leader>bf :edit .<CR>

"}}}
"{{{ `<Leader>t…` — Tags (except `<Leader>tw` — Transpose Words)

" Toggle tag browser
noremap <silent> <Leader>tb :Tagbar<CR>
" Open tag browser and give it focus
noremap <silent> <Leader>tB :TagbarOpen fj<CR>
" Show tag
noremap <silent> <Leader>ts :TagbarShowTag<CR>
" Jump through tags
noremap <silent> <Leader>tj :TagbarOpenAutoClose<CR>
" Pause Tagbar
noremap <silent> <Leader>tp :TagbarTogglePause<CR>

"}}}
"{{{ `<Leader>u…` — Undo/redo

command! -bar OpenHistoryBrowser UndotreeHide | UndotreeShow

" Toggle undo history browser
noremap <silent> <Leader>ub :UndotreeToggle<CR>

" Toggle undo history browser, giving it focus when opening it
noremap <silent> <Leader>uB :OpenHistoryBrowserWithFocus<CR>
command! -bar OpenHistoryBrowserWithFocus
	\  let g:undotree_SetFocusWhenToggle = 1
	\| OpenHistoryBrowser
	\| let g:undotree_SetFocusWhenToggle = 0

noremap <silent> <Leader>ud :OpenHistoryBrowserWithCollapsedDiff<CR>
noremap <silent> <Leader>uD :OpenHistoryBrowserWithExpandedDiff<CR>
command! -bar OpenHistoryBrowserWithCollapsedDiff
	\  let g:undotree_WindowLayout = 3
	\| OpenHistoryBrowser
command! -bar OpenHistoryBrowserWithExpandedDiff
	\  let g:undotree_WindowLayout = 4
	\| OpenHistoryBrowser

" View undo-tree leaves
noremap <silent> <Leader>ul :undolist<CR>

" Undo Write — revert to the previously written state (can be used multiple
" times to go back through the write history)
noremap <silent> <Leader>uw :earlier 1f<CR>
noremap <silent> <Leader>uW :later 1f<CR>

noremap <silent> <Leader>u<Left> :earlier<Space>
noremap <silent> <Leader>u<Right> :later<Space>

noremap <Leader>u<Up> g+
noremap <Leader>u<Down> g-

" I don’t know whether the `+1` is really necessary, but better safe.
command! -bar UndoToEarliestState execute 'earlier' len(undotree().entries)+1
command! -bar RedoToLatestState execute 'later' len(undotree().entries)+1
noremap <silent> <Leader>u<Home> :UndoToEarliestState<CR>
noremap <silent> <Leader>u<End> :RedoToLatestState<CR>

"}}}
"{{{ Files

function! FmtFileSize(file)
	return FmtBytes(getfsize(a:file))
endfunction
command! -nargs=? FileSize echo FmtFileSize(<q-args> != '' ? <q-args> : @%)

"}}}
"{{{ Opening things
" Go to Shell
noremap <silent> <Leader>gs :shell<CR>

command! -bar RCLoad source ~/.vim/vimrc | normal <C-L>
command! -bar RCEdit tabedit ~/.vim/vimrc
"}}}
"{{{ Web access

function! OpenWebURL(url)
"	execute 'silent !' . $BROWSER "'" . a:url . "'"
	execute 'tabedit' a:url
	setlocal readonly nomodifiable
endfunction
command! -nargs=1 OpenWebURL call OpenWebURL(<f-args>)

function! DfnWebsite(key, url)
	execute 'noremap <silent> <Leader>gw' . a:key . '<Space> :OpenWebURL'
		\ a:url . '<CR>'
endfunction
command! -nargs=+ DfnWebsite call DfnWebsite(<f-args>)

function! DfnWebSearch(key, cmd)
	" Defines mappings, in the `<Leader>gw` (Go to Web) space, to query a
	" Web search service, for…
	"   (a) a given word, with `?`; or
	execute 'noremap <Leader>gw' . a:key . '? :'
		\. a:cmd . '<Space>'
	"   (b) the word under the cursor, with `*`; or
	execute 'noremap <silent> <Leader>gw' . a:key . '* :'
		\. a:cmd . '<Space><cword><CR>'
	"   (c) the current selection, in Visual mode.
	"TODO
endfunction
command! -nargs=+ DfnWebSearch call DfnWebSearch(<f-args>)

function! DfnWebsiteAndSearch(key, url, cmd)
	call DfnWebsite(a:key, a:url)
	call DfnWebSearch(a:key, a:cmd)
endfunction
command! -nargs=+ DfnWebsiteAndSearch call DfnWebsiteAndSearch(<f-args>)

" Go to Web File
noremap <silent> <Leader>gwf :OpenWebURL <cfile><CR>

" `gwGs…` — Go to Web — Google — Search (Google Search)
DfnWebsiteAndSearch Gs https://encrypted.google.com/ GoogleSearch
command! -nargs=1 GoogleSearch
	\ OpenWebURL https://encrypted.google.com/search?q=<args>

" `gwWe…` — Go to Web — Wikimedia — Encylopedia (Wikipedia search)
DfnWebsiteAndSearch We https://en.wikipedia.org/ WikipediaSearch
command! -nargs=1 WikipediaSearch
	\ OpenWebURL https://en.wikipedia.org/wiki/Special:Search/<args>

" `gwWd…` — Go to Web — Wikimedia — Dictionary (Wiktionary lookup)
DfnWebsiteAndSearch Wd https://en.wiktionary.org/ WiktionaryLookup
command! -nargs=1 WiktionaryLookup
	\ OpenWebURL https://en.wiktionary.org/wiki/<args>

" `gwIeR…` — Go to Web — Internet — Engineering — RFC (IETF RFC lookup)
DfnWebSearch IeR OpenIetfRFC
command! -nargs=1 OpenIetfRFC
	\ OpenWebURL https://tools.ietf.org/html/rfc<args>
	\| setlocal readonly nomodifiable nospell filetype=rfc
	\| file IETF\ RFC\ <args>

command! -bar UseElinksForWeb UseElinksForNetrwHTTP
command! -bar UseW3mForWeb UseW3mForNetrwHTTP

" Set Web Browser: Elinks
noremap <silent> <Leader>sWBe :UseElinksForWeb<CR>
" Set Web Browser: W3m
noremap <silent> <Leader>sWBw :UseW3mForWeb<CR>

"}}}
"{{{ Tests
command! -bar ColorTest tab runtime syntax/colortest.vim

" <http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor>
command! -bar GetSyntaxAtCursor
	\ echo printf('(high: %s)  (trans: %s)  (low: %s)',
	\	synIDattr(synID(line('.'), col('.'), 1), 'name'),
	\	synIDattr(synID(line('.'), col('.'), 0), 'name'),
	\	synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name'))
"}}}

"}}}======== Mappings and Commands ==================================/

"{{{======== Auto-Commands ==========================================\

autocmd BufNewFile * nested call TryToCompleteIncompleteFileName()
function! TryToCompleteIncompleteFileName()
	let l:choices = filter(glob(@% . '*', 0, 1),
		\ 'v:val !~ ''\.swp$'' && stridx(v:val, "\n") == -1')
	if !empty(l:choices) && len(l:choices) <= 9
		let l:choice = confirm(
			\ 'File not found. Did you mean one of these? (Press Enter or ^C to skip.)',
			\ join(map(copy(l:choices), '"&".v:key." ".v:val'),
			\ "\n"), 0)
		if l:choice
			let l:bufnr = bufnr('%')
			execute 'edit' fnameescape(l:choices[l:choice - 1])
			edit
			execute 'bdelete' l:bufnr
		endif
	endif
endfunction

autocmd BufRead,BufNewFile *
	\ let &l:spellfile = $HOME.'/.vim/spell/'.&spelllang.'.utf-8.add'

"}}}======== Auto-Commands ==========================================/

"{{{======== Display Customization ==================================\

"{{{ Color scheme

" Controls whether to use the Solarized colorscheme, if available.
" This variable will be set to 0 (in § Plugins → Solarized) if the Solarized
" colorscheme is not installed and enabled.
let s:solarize = 0
" Whether I’ve customized iTerm2 to use a Solarized colorscheme.
let s:solarize_iTerm_customized = 0

let s:load_colorscheme_called = 0

function! s:load_colorscheme()
	let s:load_colorscheme_called += 1

	let l:ftcolors = '
		\	markdown -
		\	netrw !
		\'
	let l:ftcolor = matchstr(l:ftcolors, &filetype . ' \zs\S\+')

	if (s:load_colorscheme_called > 1 && l:ftcolor != '!') || s:solarize
		return
	endif

	if l:ftcolor == '' || l:ftcolor == '!'
		colorscheme desert
	elseif l:ftcolor == '-'
		" Don’t bother loading a colorscheme.
		call s:SetHighlights()
	else
		execute 'colorscheme' l:ftcolor
	endif
endfunction

autocmd VimEnter * nested call s:load_colorscheme()
" The above autocmd didn’t seem to fire when opening a directory.
autocmd FileType netrw nested call s:load_colorscheme()

"}}}

"{{{ Color line numbers differently in and out of Insert modie.
function! RecolorLineNrsForMode(insert)
	let l:nor = 'ctermfg=' . s:linenr_color
	let l:ins = 'ctermfg=' . (s:linenr_color != 'darkgreen'
		\ ? 'darkgreen' : 'green')
	let l:norc = 'ctermfg=white'
	let l:insc = l:norc
	if a:insert
		execute 'highlight LineNr' l:ins
		execute 'highlight CursorLineNr' l:insc
	else
		execute 'highlight LineNr' l:nor
		execute 'highlight CursorLineNr' l:norc
	endif
endfunction

autocmd InsertEnter * call RecolorLineNrsForMode(1)
autocmd InsertLeave * call RecolorLineNrsForMode(0)

inoremap <silent> <C-C> <C-\><C-N>:call RecolorLineNrsForMode(0)<CR>
"}}}

"{{{ Highlights

function s:SetHighlights()

let s:linenr_color = synIDattr(hlID('LineNr'), 'fg')
if s:linenr_color =~ '\v^(3|11)$'
	let s:linenr_color = 'brown'
endif

highlight CursorLineNr cterm=bold

if !s:solarize
	highlight CursorLine cterm=none
endif

if &t_Co >= 8
	highlight PmenuSbar ctermbg=4
	highlight PmenuSel ctermfg=0 ctermbg=4
	highlight PmenuThumb ctermbg=5
	highlight SignColumn ctermbg=0
endif

if &t_Co == 256
	highlight ColorColumn ctermbg=52
	highlight Comment ctermfg=20
	if (synIDattr(hlID('DiffAdd'), 'bg')
			\ + synIDattr(hlID('DiffChange'), 'bg')
			\ + synIDattr(hlID('DiffDelete'), 'bg')
			\ + synIDattr(hlID('DiffText'), 'bg')) < 7*4
		highlight DiffAdd ctermbg=23
		highlight DiffChange ctermbg=17
		highlight DiffDelete cterm=none ctermfg=53 ctermbg=52
		highlight DiffText cterm=none ctermbg=21
	endif
	highlight Folded cterm=bold ctermfg=22 ctermbg=22
	highlight PmenuSbar ctermbg=8
	highlight SpellBad ctermbg=88
	highlight SpellCap ctermbg=20
endif

call RecolorLineNrsForMode(0)

endfunction

autocmd ColorScheme * call s:SetHighlights()

"}}}

"}}}======== Display Customization ==================================/

"{{{======== File Types =============================================\

function! RegisterFileType(pattern, type)
	execute 'autocmd BufRead,BufNewFile' a:pattern
		\ 'setlocal filetype=' . a:type
endfunction

" So that ApplyGeneralSettings (called on FileType) is called even if Vim is
" started without being given a filename as argument.
autocmd VimEnter ?\\\{0\} setfiletype none

call RegisterFileType('*.mkd', 'markdown-simple')
call RegisterFileType('*.ll', 'llvm')
call RegisterFileType('*.td', 'tablegen')
call RegisterFileType('*.jx', 'xhtml')

autocmd BufRead https\\\{,1\}://* HideBadWhitespace

"}}}======== File Types =============================================/

"{{{======== Plugins ================================================\

"{{{ Airline

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_section_z = '%p ␊ %l/%L ␍ %02v ␈ %02c'
let g:airline_symbols.branch = 'Y'
let g:airline_symbols.whitespace = ''
let g:airline#extensions#csv#column_display = 'Name'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#tab_nr_type = 1

"}}} Airline
"{{{ AnsiEsc

" Interferes with `<Leader>r`.
autocmd VimEnter *
	\  if maparg('<Leader>rwp', 'n') != ''
	\|	unmap <Leader>rwp
	\| endif

"}}}
"{{{ Bufferline

let g:bufferline_echo = 0
let g:bufferline_fname_mod = ':~:.:gs \(/[^[:alpha:]]*[[:alpha:]]\)[^/]*/ \1/'

"}}} Bufferline
"{{{ delimitMate

let g:delimitMate_expand_cr = 1

"}}}
"{{{ EasyAlign

" Start interactive EasyAlign in visual mode
vmap <Enter> <Plug>(EasyAlign)
" Change Alignment — Start interactive EasyAlign with a Vim movement
nmap <Leader>ca <Plug>(EasyAlign)

"}}} EasyAlign
"{{{ EasyMotion

let g:EasyMotion_smartcase = 1

command! EasyMotionToggleUseUpper
	\  if g:EasyMotion_use_upper
	\|	let g:EasyMotion_use_upper = 0
	\|	let g:EasyMotion_keys = substitute(substitute(
	\		g:EasyMotion_keys, '\l', '', 'g'), '\u', '\l&', 'g')
	\| else
	\|	let g:EasyMotion_use_upper = 1
	\|	let g:EasyMotion_keys = substitute(substitute(
	\		g:EasyMotion_keys, '\u', '', 'g'), '\l', '\u&', 'g')
	\| endif

"autocmd VimEnter * EasyMotionToggleUseUpper

map <Space> <Plug>(easymotion-prefix)

"}}}
"{{{ Gist

if executable('pbcopy') == 1
	let g:gist_clip_command = 'pbcopy'
endif

let g:gist_detect_filetype = 1
let g:gist_show_privates = 1
let g:gist_post_private = 1

"}}}
"{{{ Insertlessly

let g:insertlessly_cleanup_trailing_ws = 0
let g:insertlessly_cleanup_all_ws = 0

"map <Esc><CR> <Plug>OpenNewline

"}}}
"{{{ Netrw

command! -bar UseElinksForNetrwHTTP
	\  let g:netrw_http_cmd = 'elinks'
	\| let g:netrw_http_xcmd = '-dump >'
command! -bar UseW3mForNetrwHTTP
	\  let g:netrw_http_cmd = 'w3m'
	\| let g:netrw_http_xcmd = '-dump >'

UseW3mForNetrwHTTP

"}}} Netrw
"{{{ SearchParty

" I use `<C-BSlash>` as the `pastetoggle` key.
map <Leader><C-L> <Plug>SearchPartyHighlightToggle

"}}}
"{{{ Sensible

" Unmap sensible.vim’s <C-L>, allowing SearchParty’s <C-L> to take its place.
if exists('s:plugin_dir') && isdirectory(s:plugin_dir . '/SearchParty')
	unmap <C-L>
endif

"}}}
"{{{ Signify

let g:signify_vcs_list = ['git']
let g:signify_sign_change = '~'

"}}} Signify
"{{{ Solarized

if exists('s:plugin_dir')
		\ && !isdirectory(s:plugin_dir . '/vim-colors-solarized')
	let s:solarize = 0
endif

if s:solarize
	let s:solarize_term_customized =
		\ ($TERM_PROGRAM != 'iTerm.app'
		\	&& s:solarize_iTerm_customized)

	if &t_Co == 256 && !s:solarize_term_customized
		let g:solarized_termcolors = 256
	endif

	function SolarizedToggleBG()
		call togglebg#map('{solarized-togglebg}')
		normal {solarized-togglebg}
		unmap {solarized-togglebg}
		unmap! {solarized-togglebg}
	endfunction

	colorscheme solarized

	highlight Normal ctermbg=0
endif

"}}}
"{{{ Tagbar

let g:tagbar_left = 1
let g:tagbar_width = 32
let g:tagbar_iconchars = ['+', '-'] " ['▸', '▾']

"autocmd BufEnter * nested call tagbar#autoopen(0)

"}}} Tagbar
"{{{ Tmuxify

" The default `<Leader>m` space is also used by SearchParty, which I find
" generally more useful.
let g:tmuxify_map_prefix = '<Leader><C-T>'

"}}}
"{{{ Tmuxline

let g:tmuxline_powerline_separators = 0
let g:tmuxline_preset = {
\	'a'   : ' #S ',
\	'b'   : '',
\	'c'   : '',
\	'win' : '#I#F#W',
\	'cwin': '#I#F#W',
\	'x'   : '',
\	'y'   : ' %F %T %z ',
\	'z'   : ' #h ',
\	'options': {'status-justify': 'left'}
\ }
let g:tmuxline_separators = {
\	'left': '', 'left_alt': '',
\	'right': '', 'right_alt': '',
\	'space': ''
\ }

"}}}
"{{{ Undotree

let g:undotree_WindowLayout = 3
let g:undotree_SplitWidth = 32

"}}}
"{{{ Unimpaired

" Disable these mappings so that I won’t use them accidentally if I mistype a
" `[o…`/`]o…` option-setting mapping. (Also, they’re deprecated anyway.)
"
" As of 2014-06-26 23:37 -0700, these mappings appear to have been removed
" upstream.
autocmd VimEnter *
	\  if maparg('[o', 'n') != ''
	\|	nunmap [o
	\| endif
	\| if maparg(']o', 'n') != ''
	\|	nunmap ]o
	\| endif

function! SwitchFileHard(to)
	if &l:modified
		echoerr 'Error: Buffer has unsaved changes'
		return
	endif
	let l:bufnr = bufnr('%')
	execute 'normal' a:to . 'f'
	execute l:bufnr . 'bdelete'
endfunction

noremap <silent> [F :call SwitchFileHard('[')<CR>
noremap <silent> ]F :call SwitchFileHard(']')<CR>

"}}}
"{{{ vim2hs

let g:haskell_conceal = 0

"}}}

"}}}======== Plugins ================================================/

"{{{======== Epilog of Miscellaneous Finalization ===================\

" Delete single-# comments in spell files older than a day when exiting Vim.
" Double-# comments are untouched, and can be used for actual comments (rather
" than commenting out words, including with ‘zw’).
autocmd VimLeavePre * runtime spell/cleanadd.vim
let g:spell_clean_limit = 60 * 60 * 24

" Vim doesn’t seem to notice my mapping of `<C-W><C-C>` until I’ve already
" used it once.
silent! normal 

augroup END

set secure

"}}}======== Epilog of Miscellaneous Finalization ===================/
