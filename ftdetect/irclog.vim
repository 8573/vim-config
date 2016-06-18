autocmd BufRead,BufNewFile */*log*weechat*,*/*weechat*log*
	\ setfiletype weechatlog

autocmd BufRead,BufNewFile */*log*irssi*,*/*irssi*log*
	\ setfiletype irssilog

autocmd BufRead,BufNewFile */*log*quassel*,*/*quassel*log*
	\ setfiletype quassellog

" `weechatlog` should cover both Irssi and Weechat logs, given that their log
" formats are similar but WeeChat’s is more flexible, and thus my syntax
" definition for it is more general.
autocmd BufRead,BufNewFile */*log*irc*,*/*irc*log*
	\ setfiletype weechatlog
