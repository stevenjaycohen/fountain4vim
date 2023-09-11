" Set FileType
au BufRead,BufNewFile *.fountain set filetype=fountain
" Set Auto-Correct File
au BufRead,BufNewFile *.fountain execute "source ".expand(g:flow_directory)."fountain-correct.vim"
