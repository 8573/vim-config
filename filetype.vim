if exists('did_load_filetypes')
	finish
endif

augroup filetypedetect

autocmd BufNewFile,BufRead GIT_HUB_EDIT_MSG setfiletype gitcommit

augroup END
