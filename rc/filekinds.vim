scriptencoding utf-8

" Common settings for classes of file-types (which I term "file-kinds", by
" analogy to "types" vs. "kinds" in certain programming languages).

if exists('g:c74d_filekinds_done')
	finish
endif

let s:fk_dir = 'lib/filekinds'
let s:fkplugin_dir = s:fk_dir . '/fkplugin'
let s:ft_lists_dir = s:fk_dir . '/type-lists'

let s:file_kinds = {
	\	'text': [],
	\		'document': [],
	\		'message': [],
	\	'code': [],
	\		'program-source': [],
	\		'configuration': [],
	\		'data-storage': [],
	\ }

function! s:apply_file_kind_settings()
	for [l:kind, l:types] in items(s:file_kinds)
		if index(l:types, &l:filetype) != -1
			call s:set_file_kind(l:kind)
		endif
	endfor
endfunction

function! s:file_kind_setup()
	if !exists('s:vim_homedir')
		if exists('g:vim_homedir')
			let s:vim_homedir = g:vim_homedir
		else
			echoerr 'Something should set either `s:vim_homedir` or `g:vim_homedir`.'
		endif
	endif

	for l:v in ['fk_dir', 'fkplugin_dir', 'ft_lists_dir']
		let s:{l:v} = s:vim_homedir . '/' . s:{l:v}
	endfor

	call s:load_file_kind_types()

	call s:apply_file_kind_settings()

	autocmd Filetype * call s:apply_file_kind_settings()
	autocmd OptionSet modifiable,readonly call s:apply_file_kind_settings()
endfunction

function! s:file_kind_type_list_path(kind)
	return s:ft_lists_dir . '/' . a:kind
endfunction

function! s:load_file_kind_types()
	for [l:kind, l:types] in items(s:file_kinds)
		call extend(l:types, s:read_file_kind_types(l:kind))
	endfor
endfunction

function! s:read_file_kind_types(kind)
	return readfile(s:file_kind_type_list_path(a:kind))
endfunction

function! s:set_file_kind(kind)
	if !exists('s:sfk_is_ours')
		if exists('*SetFileKind')
			let l:SFK_old = function('SetFileKind')
		endif

		function! SetFileKind(kind)
			call s:set_file_kind(a:kind)
		endfunction

		let s:sfk_is_ours = 1
		let l:sfk_is_mine = 1
	endif

	execute 'source' s:fkplugin_dir . '/' . a:kind . '.vim'

	let b:filekind = a:kind

	execute 'source' s:fkplugin_dir . '/all.vim'

	if exists('l:sfk_is_mine')
		delfunction SetFileKind

		unlet s:sfk_is_ours

		if exists('l:SFK_old')
			let SetFileKind = l:SFK_old
		endif
	endif
endfunction

autocmd VimEnter * call s:file_kind_setup()

let g:c74d_filekinds_done = 1

