" Tasks syntax
" Language:    Tasks
" Maintainer:  Chris Rolfs
" Last Change: Aug 7, 2015
" Version:	   0.1
" URL:         https://github.com/irrationalistic/vim-tasks

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'tasks'
endif

silent! syntax include @markdown syntax/markdown.vim
unlet! b:current_syntax

syn case match
syn sync fromstart

syn match tMarker "☐" contained
syn match tMarkerCancelled "✘" contained
syn match tMarkerComplete "✔" contained
syn match tAttribute /@\w\+\(([^)]*)\)\=/ contained
syn match tAttributeCompleted /@\w\+\(([^)]*)\)\=/ contained

syn region tTask start=/^\s*/ end=/$/ oneline keepend contains=tMarker,tAttribute
syn region tTaskDone start=/^[\s]*.*@done/ end=/$/ oneline contains=tMarkerComplete,tAttributeCompleted
syn region tTaskCancelled start=/^[\s]*.*@cancelled/ end=/$/ oneline contains=tMarkerCancelled,tAttributeCompleted
syn match tProject "^\s*.*:$"

hi def link tMarker Comment
hi def link tMarkerComplete String
hi def link tMarkerCancelled Statement
hi def link tAttribute Special
hi def link tAttributeCompleted Function
hi def link tTaskDone Comment
hi def link tTaskCancelled Comment
hi def link tProject Constant
