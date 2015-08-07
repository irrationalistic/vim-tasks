" Tasks file detection
" Language:    Tasks
" Maintainer:  Chris Rolfs
" Last Change: Aug 7, 2015
" Version:	   0.1
" URL:         https://github.com/irrationalistic/vim-tasks
"
autocmd BufNewFile,BufReadPost *.TODO,TODO,*.todo,*.todolist,*.taskpaper,*.tasks set filetype=tasks
