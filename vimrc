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
"{{{ Load information re running NixOS installation (if any)

let s:c74d_NixOS_params_file = '/etc/c74d/NixOS/c74d-params.json'

function! LoadC74DNixOSParams()
	try
		let l:json = join(readfile(s:c74d_NixOS_params_file), '\n')
		return json_decode(l:json)
	catch /.*/
	endtry
	return {}
endfunction

let s:c74d_NixOS_params = LoadC74DNixOSParams()

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
let s:vim_homedir = g:vim_homedir
autocmd VimEnter *
	\ let g:vim_homedir = s:vim_homedir

" TODO: Check that `g:vim_homedir` is writable only for owner.

let g:vimrc_orig_runtimepath = &g:runtimepath
let g:vimrc_orig_runtimepath_dirs = split(g:vimrc_orig_runtimepath, ',')

"}}}
"{{{ Load misc. other configuration scripts

let s:rc = [
	\ 'lib/digraphs.vim',
	\ ]

for s:f in s:rc
	let s:f = g:vim_homedir . '/' . s:f
	if filereadable(s:f)
		execute 'source' s:f
	endif
endfor

unlet s:rc s:f

"}}}
"}}}
"{{{ Plug-in loading

if !exists('g:vimrc_NO_PLUGINS')

call plug#begin('~/.vim/plugged')

" My NixOS configuration may also not provide Vim plugins if it's in minimal
" mode, but in that case this configuration should follow the same standard
" and not provide the plugins that the NixOS configuration wouldn't, so I
" don't check whether the NixOS configuration is in minimal mode here.
let s:already_have_system_plugins =
	\ isdirectory('/etc/c74d/NixOS')
let s:already_have_personal_plugins =
	\ get(s:c74d_NixOS_params, 'personal')

if !s:already_have_system_plugins
	Plug 'tpope/vim-sensible'

	" Dependency plug-ins.
	Plug 'tpope/vim-repeat'

	" UI/misc. plug-ins.
	Plug 'bitc/vim-bad-whitespace'
	Plug 'ciaranm/securemodelines'
	Plug 'mhinz/vim-hugefile'
	Plug 'powerman/vim-plugin-AnsiEsc'
endif

if !s:already_have_personal_plugins
	" Dependency plug-ins.
	Plug 'dahu/Nexus'
	" Dependency for vim-snipmate
	Plug 'MarcWeber/vim-addon-mw-utils'
	" Dependency for vim-snipmate
	Plug 'tomtom/tlib_vim'

	" UI/misc. plug-ins.
	Plug 'Raimondi/delimitMate'
	Plug 'dahu/vim-fanfingtastic'
	Plug 'easymotion/vim-easymotion'
	Plug 'editorconfig/editorconfig-vim'
	Plug 'garbas/vim-snipmate'
	Plug 'honza/vim-snippets'
	Plug 'mbbill/undotree'
	Plug 'thinca/vim-visualstar'
	Plug 'tpope/vim-abolish'
	Plug 'tpope/vim-commentary'
	Plug 'tpope/vim-dispatch'
	Plug 'tpope/vim-endwise'
	Plug 'tpope/vim-eunuch'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-sleuth'
	Plug 'tpope/vim-speeddating'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-unimpaired'

	" File-type-specific plug-ins
	Plug 'rust-lang/rust.vim', {'for': 'rust'}
	Plug 'racer-rust/vim-racer', {'for': 'rust'}
	Plug 'lervag/vimtex', {'for': ['tex', 'plaintex']}
endif

" UI/misc. plug-ins.
Plug 'Shougo/denite.nvim'
Plug 'tpope/vim-characterize'
Plug 'vim-airline/vim-airline'

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
set nojoinspaces
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
set showcmd
set showfulltag
set showtabline=2
set smartcase
set splitright
set suffixes+=~,.aux,.bak,.bbl,.blg,.brf,.cb,.dvi,.idx,.ilg,.ind,.inx,.jpg,.o,.out,.png,.swp,.toc
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

let g:mapleader = ' '

let g:vim_main_spelllang = 'en'

"}}}
"{{{ GUI settings

if has('gui_running')
	set guifont=DejaVu\ Sans\ Mono\ 13,Monospace\ 12

	if fnamemodify(bufname('%'), ':h:r') =~# 'vim-pager'
		" The only difference between size 12 and size 13 of DejaVu
		" Sans Mono seems to be that the latter has slightly more
		" vertical space between lines, which I seem to like for
		" editing and seem to dislike for paging.
		set guifont=DejaVu\ Sans\ Mono\ 12,Monospace\ 12
	endif
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
"{{{ PromptTimezone()
function! PromptTimezone()
	let l:tz = PromptLine("Timezone: ")

	let l:tz_abbrs = {
		\ "ET": "America/New_York",
		\ "CT": "America/Chicago",
		\ "MT": "America/Denver",
		\ "PT": "America/Los_Angeles",
		\ }

	for [l:tz_abbr, l:tz_full] in items(l:tz_abbrs)
		if l:tz ==? l:tz_abbr
			return l:tz_full
		endif
	endfor

	return l:tz
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
"{{{ SHA256AsNr(string)
function! SHA256AsNr(string)
	return StrToNrWrapping(SHA256(a:string), 16)
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
"{{{ StrToNrWrapping(string, radix)
let s:StrToNrWrapping_digits = '0123456789abcdefghijklmnopqrstuvwxyz'
function! StrToNrWrapping(string, radix)
	let l:s = tolower(a:string)
	let l:i = 0
	let l:i_end = strlen(l:s)
	let l:r = 0
	while l:i < l:i_end
		let l:r = l:r * a:radix
			\ + stridx(s:StrToNrWrapping_digits, l:s[l:i])
		let l:i += 1
	endwhile
	return l:r
endfunction
"}}}
"{{{ Qalc(expr)
function! Qalc(expr)
	return substitute(system('qalc ' . ShellEsc(a:expr)),
		\ '.* = \(.*\)\n', '\1', '')
endfunction
"}}}
"{{{ WithOrigRuntimepath(action[, args...])
function! WithOrigRuntimepath(action)
	let l:rtp = &runtimepath
	let &runtimepath = g:vimrc_orig_runtimepath

	if type(a:action) == type(function('tr'))
		return call(a:action, a:000)
	elseif type(a:action) == type('')
		if a:0 != 0
			throw "`args` may only be provided if `action` is a function"
		endif
		execute a:action
	else
		throw "Don't know how to run `action`"
	endif

	let &runtimepath = l:rtp
endfunction
"}}}
"{{{ LookUpFileInOrigRuntimepath(filename)
function! LookUpFileInOrigRuntimepath(filename)
	for l:dir in g:vimrc_orig_runtimepath_dirs
		let l:file = l:dir + '/' + a:filename
		if filereadable(l:file)
			return l:file
		endif
	endfor
endfunction
"}}}
"{{{ LocalSource(filepath)
function! LocalSource(filepath)
	execute 'source' g:vim_homedir . '/' . a:filepath
endfunction
"}}}
"{{{ AppendToCommaSeparatedOption(option_name, value_to_append)
function AppendToCommaSeparatedOption(option, value_to_append)
	execute 'let l:old_val = &' . a:option

	if type(l:old_val) != type('')
		throw 'AppendToCommaSeparatedOption is only for use on options whose values are of string type.'
	endif

	let l:new_val = (l:old_val == '' ? '' : ',') . a:value_to_append

	execute 'let &' . a:option . ' .= l:new_val'
endfunction
"}}}
"{{{ GlobEsc(string)
" Escape a string for use in `glob()`.
function! GlobEsc(string)
	return substitute(a:string, '[[*?]', '[&]', 'g')
endfunction

Assert GlobEsc('') ==# ''
Assert GlobEsc('abc') ==# 'abc'
Assert GlobEsc('a[?b*]c') ==# 'a[[][?]b[*]]c'
"}}}
"{{{ EchoHl(hl, args...)
" Echo the `args` with highlighting `hl`. Unlike `:echohl`, this resets the
" highlighting afterward. For echoing multiple highlighted lines, use
" `:echohl`.
function! EchoHl(hl, ...)
	execute 'echohl' a:hl
	echo join(a:000)
	echohl None
endfunction
"}}}
"}}}
"{{{ Mappings and commands
"{{{ Miscellaneous

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

" Cf. `gp`.
vnoremap gy y`>

" With this, if I use a leader-prefixed mapping that turns out to not exist,
" it gets dumped into a command line, rather than being interpreted sans
" leader.
noremap <Leader> :

imap <Esc> <C-O><Leader>

noremap <C-H> :tab help<Space>

imap <C-L> <C-C><C-L>gi

noremap Q gq

vnoremap <A-<> <gv
vnoremap <A->> >gv

" Matches 'pastetoggle' (which would itself work if I didn't re-`imap` <Esc>
" above).
inoremap <silent> <Esc>\ <C-O>:set invpaste<CR>

vnoremap <C-R> r█

"{{{ `:CountOccurrences`

function! CountOccurrences(pattern)
	let s:n = 0
	execute 'global' . a:pattern . 'let s:n += 1'
	echo s:n
	unlet s:n
endfunction

command! -nargs=1 CountOccurrences call CountOccurrences(<q-args>)

"}}}
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
		\ ':call <SID>LeaderInsert(' string(s:m) ')<CR>'
endfor

let [s:leaderInserts, s:leaderInsertKeys] = [{}, []]

"{{{ s:LeaderInsert(imode)
function! s:LeaderInsert(imode)
	if a:imode !~? '^[iao]$'
		throw 's:LeaderInsert(imode): `imode` must be in ''iIaAoO'', but it is ' . string(a:imode)
	endif

	let [l:s, l:c] = ['', '']

	echon '<Leader>' a:imode

	while 1
		let l:c = ReadChar()

		echon l:c

		if l:c == "\<C-C>"
			return
		elseif l:c == "\<NL>" || l:c == "\<CR>"
			let l:s = PromptLine('Complete leader-insert macro: ',
				\ '', 'custom,LeaderInsertCompleter')
		else
			let l:s .= exists('mapleader')
				\ && maparg(l:c) == mapleader
				\ ? mapleader : l:c
		endif


		if has_key(s:leaderInserts, l:s)
			execute 'normal!' a:imode
				\ . "\<C-R>=InputLocked("
				\ string(s:leaderInserts[l:s])
				\ ")\<CR>\<Right>"
			return
		endif

		if match(s:leaderInsertKeys,
				\ '^' . VerbatimPattern(l:s)) == -1
			echoerr 'leader-insert macro' string(l:s) 'not found'
			return
		endif
	endwhile

	throw 'unreachable'
endfunction
"}}}
"{{{ LeaderInsertCompleter(...)
function! LeaderInsertCompleter(...)
	return join(s:leaderInsertKeys, "\n")
endfunction
"}}}
"{{{ DfnInsertMacro(key, expr)
function! DfnInsertMacro(key, expr)
	let s:leaderInserts[a:key] = a:expr
	call add(s:leaderInsertKeys, a:key)
endfunction
"}}}

"}}}
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

function! s:DfnInsertTimestampKey(key, fmt)
	let l:fmt = a:fmt =~ '%' ? shellescape(a:fmt) : a:fmt

	function s:m(key, expr)
		let l:x = 'substitute(' . a:expr . ', ''\n$'', '''', '''')'
		"execute 'noremap <silent> <Leader>it' . a:key
		"	\ '"=' . l:x . '<CR>P:Right<CR>'
		"execute 'inoremap <silent> <Esc>it' . a:key
		"	\ '<C-R><C-R>=' . l:x . '<CR>'
		call DfnInsertMacro('t' . a:key, l:x)
	endfunction

	call s:m('u' . a:key,
		\ 'system(''date -u '' . ShellEsc(''+'' . '
		\ . l:fmt . ' . '' %Z''))')
	call s:m('l' . a:key,
		\ 'strftime(' . l:fmt . '.'' %z'')')
	call s:m('z' . a:key,
		\ 'system("TZ=" . ShellEsc(PromptTimezone()) . " date " . ShellEsc("+" . '
		\ . l:fmt . ' . " %z"))')
	call s:m('U' . a:key,
		\ 'system("date -u " . ShellEsc("+" . ' . l:fmt . '))')
	call s:m('L' . a:key,
		\ 'strftime(' . l:fmt . ')')
	call s:m('Z' . a:key,
		\ 'system("TZ=" . ShellEsc(PromptTimezone()) . " date " . ShellEsc("+" . '
		\ . l:fmt . '))')

	delfunction s:m
endfunction

for [s:key, s:fmt] in [
\	['s', '%F %T'],
\	['m', '%F %H:%M'],
\	['h', '%F %H'],
\	['d', '%F'],
\	['n', '%Y-%m'],
\	['y', '%Y'],
\	['S', '%S'],
\	['M', '%M:%S'],
\	['H', '%T'],
\	['D', '%d %T'],
\	['N', '%m-%d %T'],
\	['Y', '%F %T'],
\	['z', '%z'],
\	['Z', '%Z'],
\	['x', 'PromptLine("strftime format string: ")']
\]
	call s:DfnInsertTimestampKey(s:key, s:fmt)
endfor
unlet s:key s:fmt

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
call DfnInsertMacro('\Em', string('[…]'))

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
"{{{ Denite

noremap <silent> <Leader><CR>b :Denite<Space>buffer<CR>
noremap <silent> <Leader><CR>f :Denite<Space>file_rec<CR>
noremap <silent> <Leader><CR>o :Denite<Space>buffer file_rec<CR>
noremap <silent> <Leader><CR>g :Denite<Space>grep<CR>

" Use Ripgrep for `:Denite grep`. Copied from Denite help.
if executable('rg')
	call denite#custom#var('grep', 'command', ['rg'])
	call denite#custom#var('grep', 'default_opts',
		\ ['--vimgrep', '--no-heading'])
	call denite#custom#var('grep', 'recursive_opts', [])
	call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
	call denite#custom#var('grep', 'separator', ['--'])
	call denite#custom#var('grep', 'final_opts', [])
endif

"}}}
"{{{ EasyMotion

let g:EasyMotion_smartcase = 1

map <CR> <Plug>(easymotion-s2)

"}}}
"{{{ EditorConfig

if !exists('g:EditorConfig_exclude_patterns')
	let g:EditorConfig_exclude_patterns = []
endif

let g:EditorConfig_exclude_patterns += [
	\ 'fugitive://.*',
	\ 'scp://.*'
	\ ]

"}}}
"{{{ LanguageClient

function s:LanguageClient_setup_global()
	if !exists('g:LanguageClient_serverCommands')
		let g:LanguageClient_serverCommands = {}
	endif

	if exists('$c74d_NixOS_Rust_env_path')
		for l:subpath in ['/bin/rls', '/bin/rust-analyzer']
			let l:path = $c74d_NixOS_Rust_env_path .. l:subpath
			if executable(l:path)
				let g:LanguageClient_serverCommands['rust'] =
					\ [l:path]
				break
			endif
		endfor
	endif

	" The Markdown doesn't get rendered, so I rather would read plain
	" text.
	let g:LanguageClient_preferredMarkupKind = ['plaintext', 'markdown']

	let g:LanguageClient_selectionUI = "fzf"
	let g:LanguageClient_fzfContextMenu = 1
endfunction

function s:LanguageClient_setup_local()
	if !has_key(g:LanguageClient_serverCommands, &filetype)
		return
	endif

	nnoremap <buffer> <silent> K
		\ :call LanguageClient#textDocument_hover()<CR>

	nnoremap <buffer> <silent> gd
		\ :vsplit <Bar>
		\  call LanguageClient#textDocument_definition()<CR>

	" By analogy to tmux keybindings
	nnoremap <buffer> <silent> g"d
		\ :split <Bar>
		\  call LanguageClient#textDocument_definition()<CR>

	nnoremap <buffer> <silent> gD
		\ :call LanguageClient#textDocument_definition()<CR>

	nnoremap <buffer> <silent> <Leader>l
		\ :call LanguageClient_contextMenu()<CR>

	setlocal completefunc=LanguageClient#complete

	let b:LanguageClient_set_up = 1
endfunction

call s:LanguageClient_setup_global()
autocmd FileType * call s:LanguageClient_setup_local()

"}}}
"{{{ Netrw

" I tire of the difficulties of closing Netrw buffers. Silently execute them
" with likely excessive prejudice.
function! s:netrw_close()
	for l:i in range(1, bufnr('$'))
		if getbufvar(l:i, '&filetype') == 'netrw'
			silent! execute 'bwipeout' l:i
			if getbufvar(l:i - 1, '&filetype') == ''
				silent! execute 'bwipeout' (l:i - 1)
			endif
		endif
	endfor
endfunction

autocmd BufEnter * call s:netrw_close()

"}}}
"{{{ Racer

function s:Racer_setup_global()
	let g:Racer_is_found = s:Racer_setup_cmd()
endfunction

" Return whether Racer was found.
function s:Racer_setup_cmd()
	if exists('$c74d_NixOS_Rust_env_path')
		let g:racer_cmd = $c74d_NixOS_Rust_env_path .. '/bin/racer'
		return executable(g:racer_cmd)
		" Even if Racer doesn't exist (executably) at this path, leave
		" `g:racer_cmd` set thus: if I'm on NixOS, and there's no
		" Racer there, then assume there's no Racer elsewhere either.
	elseif executable('racer')
		unlet! g:racer_cmd
		return 1
	endif

	return 0
endfunction

" Used if Racer is present
function s:Racer_setup_local_1()
	nmap <buffer> <silent> <Leader>K <Plug>(rust-doc)

	if exists('b:LanguageClient_set_up')
			\ && has_key(g:LanguageClient_serverCommands, 'rust')
		return
	endif
	" After this are substitutes for LanguageClient functionality.

	nmap <buffer> <silent> gd <Plug>(rust-def-vertical)

	" By analogy to tmux keybindings
	nmap <buffer> <silent> g"d <Plug>(rust-def-split)

	nmap <buffer> <silent> gD <Plug>(rust-def)
endfunction

" Used if Racer is missing
function s:Racer_setup_local_0()
	let l:Map = {key -> execute('nmap <buffer> <silent> ' .. key
		\ .. " :call EchoHl('WarningMsg', 'Racer was not found.')<CR>"
		\ )}

	call l:Map('<Leader>K')

	if exists('b:LanguageClient_set_up')
			\ && has_key(g:LanguageClient_serverCommands, 'rust')
		return
	endif

	call l:Map('gd')
	call l:Map('g"d')
	call l:Map('gD')
endfunction

call s:Racer_setup_global()
autocmd FileType rust call s:Racer_setup_local_{g:Racer_is_found}()

"}}}
"{{{ Rust.vim

let g:rust_fold = 1

"if executable('/run/current-system/sw/bin/nix-instantiate')
"	let g:rustc_path =
"		\ '$(nix-instantiate "<nixpkgs>" --attr rustc 2>/dev/null)'
"	let g:rustfmt_command =
"		\ '$(nix-instantiate "<nixpkgs>" --attr rustfmt 2>/dev/null)'
"endif

"}}}
"{{{ securemodelines

" NOTE: Many strings that I might wish to use as 'foldmarker's (particularly
" in syntaxes in which the default "{{{,}}}" are otherwise meaningful) are not
" accepted by `securemodelines.vim`, for security reasons:
" <https://github.com/ciaranm/securemodelines/issues/12>.

let g:secure_modelines_verbose = 1

autocmd BufReadPre,StdinReadPre * ++once call s:configure_securemodelines()
function s:configure_securemodelines()
	let g:secure_modelines_allowed_items += [
		\ 'foldclose', 'fcl',
		\ 'foldcolumn', 'fdc',
		\ 'foldenable', 'fen', 'nofoldenable', 'nofen',
		\ 'foldignore', 'fdi',
		\ 'foldlevel', 'fdl',
		\ 'foldmarker', 'fmr',
		\ 'foldminlines', 'fml',
		\ 'foldnestmax', 'fdn'
		\ ]
endfunction

"}}}
"{{{ undotree

let g:undotree_WindowLayout = 3
let g:undotree_SplitWidth = 32

"}}}
"{{{ Vim-LaTeX

"autocmd FileType tex call s:configure_Vim_LaTeX()
"function s:configure_Vim_LaTeX()
"	let b:Imap_FreezeImap = 1
"endfunction

"}}}
"{{{ vimtex

let g:vimtex_fold_enabled = 1

autocmd FileType tex call s:configure_vimtex()
function s:configure_vimtex()
	" ...
endfunction

"}}}
"}}}
"{{{ Autocommands

autocmd BufNewFile * nested call TryToCompleteIncompleteFileName()
function! TryToCompleteIncompleteFileName()
	let l:choices = filter(glob(GlobEsc(@%) . '*', 0, 1),
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

autocmd BufRead,BufNewFile * call s:set_spellfile()
function s:set_spellfile()
	let l:spelllangs = ['xx@etc', g:vim_main_spelllang]
	let l:map_expr = 's:vim_homedir . "/spell/" . v:val . "." . &l:encoding . ".add"'
	let l:spellfiles = join(map(l:spelllangs, l:map_expr), ',')
	call AppendToCommaSeparatedOption('l:spellfile', l:spellfiles)
endfunction

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
	let l:normal_hl = has('gui_running')
		\ ? 'guifg=' . s:linenr_color
		\ : 'ctermfg=' . s:linenr_color
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

if has('gui_running') && match(s:linenr_color, '^\d*$') != -1
	" This function will be called again later, and letting it continue
	" now would result in `RecolorLineNrsForMode` using color identifiers
	" that are invalid in GUI mode.
	return
endif

highlight Normal guibg=grey10
highlight NonText guibg=grey10

highlight CursorLine cterm=none guibg=grey20
highlight CursorLineNr cterm=bold

" [2020-06-03] The default `guibg=Magenta` is okay for ye olde completion
" menu, but now plugins are using popup windows for significant blobs of text,
" such as documentation of a function under the cursor, which are painful to
" read on magenta.
highlight Pmenu guibg=grey25

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

call LocalSource('rc/filekinds.vim')

let g:tex_no_error = 1

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
