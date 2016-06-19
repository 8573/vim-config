scriptencoding utf-8

"{{{ Prolog

set nocompatible

augroup vimrc
autocmd!

"{{{ Functions needed this early
"{{{ GetUID()
function! GetUID()
	let l:exes = [
		\ '/usr/bin/id',
		\ '/run/current-system/sw/bin/id',
		\ ]

	for l:exe in l:exes
		if executable(l:exe)
			return [str2nr(system(l:exe . ' -u'))]
		endif
	endfor

	return []
endfunction
"}}}
"}}}
"{{{ Check whether we're running as superuser

if GetUID() == [0]
	echomsg 'NOTICE: running as superuser (UID 0) -- disabling plugins!'
	let g:vimrc_SUPERUSER_MODE = 1
	let g:vimrc_NO_PLUGINS = 1
endif

if GetUID() == []
	echomsg 'NOTICE: possibly running as superuser (UID unknown) -- disabling plugins!'
	let g:vimrc_SUPERUSER_MODE = 1
	let g:vimrc_NO_PLUGINS = 1
endif

"}}}
"{{{ Save important paths to variables

let g:vimrc_HOME =
	\ !exists('g:vimrc_SUPERUSER_MODE')
	\	? fnamemodify('~/', ':p:s./$..')
	\	: ( $USER ==# 'root'
	\		? fnamemodify('~root/', ':p:s./$..')
	\		: ( filereadable('/dev/null')
	\			? '/dev/null'
	\			: ''
	\		)
	\	)

let g:vim_homedir = g:vimrc_HOME . '/.vim'

" TODO: Check that `g:vim_homedir` is writable only for owner.

"}}}
"}}}
"{{{ Plug-in loading

if !exists('g:vimrc_NO_PLUGINS')

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'

" Dependency plug-ins.
Plug 'tpope/vim-repeat'
Plug 'dahu/Nexus'

" UI/misc. plug-ins.
Plug 'Raimondi/delimitMate'
Plug 'Raimondi/vim-transpose-words'
Plug 'bitc/vim-bad-whitespace'
Plug 'ciaranm/securemodelines'
Plug 'dahu/vim-KWEasy'
Plug 'dahu/vim-fanfingtastic'
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/vim-easy-align'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-hugefile'
Plug 'rking/ag.vim'
Plug 'thinca/vim-visualstar'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-characterize'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'

" File-type-specific plug-ins.
Plug 'rust-lang/rust.vim', {'for': 'rust'}
Plug 'racer-rust/vim-racer', {'for': 'rust'}

call plug#end()

endif

"}}}
"{{{ Settings
"{{{ General settings

set noautowrite
set background=dark
set backup
set backupcopy=yes
let &backupdir = g:vim_homedir . '/backups'
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
	let &undodir = g:vim_homedir . '/undohist'
	set undofile
endif
set viminfo+=h
set wildmode=longest:full
set wrapscan

setglobal fileencoding=utf-8

let g:vim_main_spelllang = 'en'

"}}}
"{{{ GUI settings

if has('gui_running')
	set guifont=DejaVu\ Sans\ Mono\ 13,Monospace\ 12
endif

"}}}
"}}}
"{{{ Misc. variables

let g:unit_prefixes = split('yotta zetta exa peta tera giga mega kilo hecto deca deci centi milli micro nano pico femto atto zepto yocto', ' ')
let g:units_of_measure = split('metre meter gram second ampere kelvin mole candela radian steradian hertz newton pascal joule watt coulomb volt farad ohm siemens weber tesla henry degree lumen lux becquerel gray sievert katal byte bit octet trit nibble semioctet quartet seminibble', ' ')

"}}}
"{{{ General functions
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
"{{{ NrToChar(n[, only_want_UTF8])
" `only_want_UTF8` is Boolean, defaulting to true.
function! NrToChar(n, ...)
	let l:only_want_UTF8 = a:0 ? a:1 : 1

	if v:version >= 704
		return nr2char(a:n, l:only_want_UTF8)
	endif

	if l:only_want_UTF8
		if &encoding ==? 'utf-8' || &encoding ==? 'utf8'
			return nr2char(a:n)
		else
			let l:old_enc = &encoding
			let &encoding = 'utf-8'
			let l:r = nr2char(a:n)
			let &encoding = l:old_enc
			return l:r
		endif
	endif

	" Any encoding is acceptable.
	return nr2char(a:n)
endfunction

Assert NrToChar(1, 1) ==# ''
Assert NrToChar(1, 0) ==# ''
Assert NrToChar(127, 1) ==# ''
Assert NrToChar(127, 0) ==# ''
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
		\ : matchstr(system('sha256sum - <<<'
			\ . ShellEsc(a:string) . ')'), '\S\+')
endfunction
"}}}
"{{{ MD5(string)
function! MD5(string)
	return matchstr(
		\ system('md5sum - <<<' . ShellEsc(a:string) . ')'), '\S\+')
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
"}}}
"{{{ Mappings and commands
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
"{{{ Spell files

command! UpdateSpellfile call UpdateSpellfile()

function! UpdateSpellfile()
	let l:spelldir = g:vim_homedir . '/spell'
	let l:langenc = g:vim_main_spelllang . '.' . &l:encoding
	let l:wordfile_main = l:spelldir . '/' . l:langenc . '.add'
	let l:wordfile_misc = matchstr(split(&l:spellfile, ','), "xx@etc")
	" `-t` is deprecated by GNU, but `--tmpdir` is invalid for BSD
	" `mktemp`.
	let l:wordfile_both = system('mktemp -t vim-spell-add.XXXXXXXXXX')
	let l:spellfile = l:spelldir . '/' . l:langenc . '.add.spl'

	execute '!cat' l:wordfile_main l:wordfile_misc '>' l:wordfile_both
	execute 'mkspell!' l:spellfile l:wordfile_both
	call delete(l:wordfile_both)
endfunction

"}}}
"}}}
"{{{ Plug-in configuration
"{{{ Airline

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_section_z = '%3p%%  ln %l/%L  col %02v  byte %02c'
let g:airline_symbols.branch = 'Y'
let g:airline_symbols.whitespace = ''
let g:airline#extensions#csv#column_display = 'Name'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#tab_nr_type = 1

"}}}
"{{{ delimitMate

let g:delimitMate_expand_cr = 1

"}}}
"{{{ EasyMotion

let g:EasyMotion_smartcase = 1

"}}}
"{{{ Racer

if executable('/run/current-system/sw/bin/racer')
	" With Racer installed via Nix, this variable won't actually be used,
	" but the vim-racer plugin will error out if it's left unset or is set
	" to a path that's not that of a directory, so set this variable to a
	" path known to be that of a directory.
	let $RUST_SRC_PATH = '/run'
endif

"}}}
"{{{ undotree

let g:undotree_WindowLayout = 3
let g:undotree_SplitWidth = 32

"}}}
"}}}
"{{{ Autocommands

autocmd BufNewFile * nested call TryToCompleteIncompleteFileName()
function! TryToCompleteIncompleteFileName()
	let l:choices = filter(glob(@% . '*', 0, 1),
		\ 'v:val !~ ''\.swp$'' && stridx(v:val, "\n") == -1')
	if empty(l:choices) || len(l:choices) > 9
		return
	endif
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
endfunction

autocmd BufRead,BufNewFile *
	\ let &l:spellfile = join(map(
	\   ['xx@etc', g:vim_main_spelllang],
	\   'g:vim_homedir . "/spell/" . v:val . "." . &l:encoding . ".add"'),
	\   ',')

"}}}
"{{{ Display customization
"{{{ Color scheme

let s:load_colorscheme_called = 0

function! s:load_colorscheme()
	let s:load_colorscheme_called += 1

	let l:ftcolors = '
		\	netrw !
		\'
	let l:ftcolor = matchstr(l:ftcolors, &filetype . ' \zs\S\+')

	if (s:load_colorscheme_called > 1 && l:ftcolor != '!')
		return
	endif

	if l:ftcolor == '' || l:ftcolor == '!' || &filetype == ''
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
"{{{ Color line numbers differently in and out of Insert mode.
function! RecolorLineNrsForMode(insert)
	let l:normal_hl =
		\ 'ctermfg=' . s:linenr_color . ' guifg=' . s:linenr_color
	let l:insert_linenr_color_cterm = s:linenr_color !=? 'darkgreen'
		\ ? 'darkgreen' : 'green'
	let l:insert_linenr_color_gui = s:linenr_color !=? 'cyan'
		\ ? 'cyan' : 'red'
	let l:insert_hl =
		\ 'ctermfg=' . l:insert_linenr_color_cterm
		\ . ' guifg=' . l:insert_linenr_color_gui
	let l:normal_cursor_hl = 'ctermfg=white'
	let l:insert_cursor_hl = l:normal_cursor_hl
	if a:insert
		execute 'highlight LineNr' l:insert_hl
		execute 'highlight CursorLineNr' l:insert_cursor_hl
	else
		execute 'highlight LineNr' l:normal_hl
		execute 'highlight CursorLineNr' l:normal_cursor_hl
	endif
endfunction

autocmd InsertEnter * call RecolorLineNrsForMode(1)
autocmd InsertLeave * call RecolorLineNrsForMode(0)

inoremap <silent> <C-C> <C-\><C-N>:call RecolorLineNrsForMode(0)<CR>
"}}}
"{{{ Highlights

function! s:SetHighlights()

let s:linenr_color = synIDattr(hlID('LineNr'), 'fg')

highlight NonText guibg=grey20

highlight CursorLine cterm=none
highlight CursorLineNr cterm=bold

if &t_Co >= 8
	highlight SignColumn ctermbg=0
endif

if &t_Co == 256
	highlight ColorColumn ctermbg=52
	if (synIDattr(hlID('DiffAdd'), 'bg')
			\ + synIDattr(hlID('DiffChange'), 'bg')
			\ + synIDattr(hlID('DiffDelete'), 'bg')
			\ + synIDattr(hlID('DiffText'), 'bg')) < 7*4
		highlight DiffAdd ctermbg=23
		highlight DiffChange ctermbg=17
		highlight DiffDelete cterm=none ctermfg=53 ctermbg=52
		highlight DiffText cterm=none ctermbg=21
	endif
	highlight Folded cterm=bold ctermfg=44 ctermbg=22
	highlight SpellBad ctermbg=88
	highlight SpellCap ctermbg=20
endif

call RecolorLineNrsForMode(0)

if exists(':AirlineRefresh') == 2
	AirlineRefresh
endif

endfunction

autocmd ColorScheme * call s:SetHighlights()

"}}}
"}}}
"{{{ File types

function! RegisterFileType(pattern, type)
	execute 'autocmd BufRead,BufNewFile' a:pattern
		\ 'setlocal filetype=' . a:type
endfunction

call RegisterFileType('GIT_HUB_EDIT_MSG', 'gitcommit')

"}}}
"{{{ Epilog
"{{{ Create state directories

"{{{ s:mkdir(dir)
function! s:mkdir(dir)
	let l:dir = fnamemodify(a:dir, ":p")

	let l:display_dir = fnamemodify(l:dir, ":~")

	if isdirectory(l:dir)
		return
	endif

	let l:parent_dir = fnamemodify(l:dir, ":h")
	if filewritable(l:parent_dir) != 2
		echomsg 'Cannot create directory `' . l:display_dir .
			'`, because parent directory is not writable or does not exist.'
		return
	endif

	if !exists("*mkdir")
		echomsg 'Cannot create directory `' . l:display_dir .
			'`, because `mkdir` function is not available.'
		return
	endif

	call mkdir(l:dir, "", 0700)
endfunction
"}}}

call s:mkdir(&g:backupdir)
call s:mkdir(&g:undodir)

"}}}

" Delete single-# comments in spell files older than a day when exiting Vim.
" Double-# comments are untouched, and can be used for actual comments (rather
" than commenting out words, including with ‘zw’).
autocmd VimLeavePre * runtime spell/cleanadd.vim
let g:spell_clean_limit = 60 * 60 * 24

augroup END

" <https://stackoverflow.com/a/3164830>
set noexrc
set secure

"}}}
