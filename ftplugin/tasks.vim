" Tasks plugin
" Language:    Tasks
" Maintainer:  Chris Rolfs
" Last Change: Aug 7, 2015
" Version:	   0.1
" URL:         https://github.com/irrationalistic/vim-tasks

if exists("b:loaded_tasks")
  finish
endif
let b:loaded_tasks = 1

" MAPPINGS
nnoremap <buffer> <leader>n :call NewTask(1)<cr>
nnoremap <buffer> <leader>N :call NewTask(-1)<cr>
nnoremap <buffer> <leader>d :call TaskComplete()<cr>
nnoremap <buffer> <leader>x :call TaskCancel()<cr>
nnoremap <buffer> <leader>a :call TasksArchive()<cr>

" GLOBALS

" Helper for initializing defaults
" (https://github.com/scrooloose/nerdtree/blob/master/plugin/NERD_tree.vim#L39)
function! s:initVariable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . substitute(a:value, "'", "''", "g") . "'"
    return 1
  endif
  return 0
endfunc

call s:initVariable('g:TasksMarkerBase', '☐')
call s:initVariable('g:TasksMarkerDone', '✔')
call s:initVariable('g:TasksMarkerCancelled', '✘')
call s:initVariable('g:TasksDateFormat', '%Y-%m-%d %H:%M')
call s:initVariable('g:TasksAttributeMarker', '@')
call s:initVariable('g:TasksArchiveSeparator', '＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿')

let b:regesc = '[]()?.*@='

" LOCALS
let s:regProject = '^\s*.*:$'
let s:regMarker = join([escape(g:TasksMarkerBase, b:regesc), escape(g:TasksMarkerDone, b:regesc), escape(g:TasksMarkerCancelled, b:regesc)], '\|')
let s:regDone = g:TasksAttributeMarker . 'done'
let s:regCancelled = g:TasksAttributeMarker . 'cancelled'
let s:regAttribute = g:TasksAttributeMarker . '\w\+\(([^)]*)\)\='
let s:dateFormat = g:TasksDateFormat

function! Trim(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! NewTask(direction)
  let l:line = getline('.')
  let l:isMatch = match(l:line, s:regProject)
  let l:text = g:TasksMarkerBase . ' '

  if a:direction == -1
    exec 'normal O' . l:text
  else
    exec 'normal o' . l:text
  endif

  if l:isMatch > -1
    exec 'normal >>'
  endif

  startinsert!
endfunc

function! SetLineMarker(marker)
  " if there is a marker, swap it out.
  " If there is no marker, add it in at first non-whitespace
  let l:line = getline('.')
  let l:markerMatch = match(l:line, s:regMarker)
  if l:markerMatch > -1
    call cursor(line('.'), l:markerMatch + 1)
    exec 'normal R' . a:marker
  endif
endfunc

function! AddAttribute(name, value)
  " at the end of the line, insert in the attribute:
  let l:attVal = ''
  if a:value != ''
    let l:attVal = '(' . a:value . ')'
  endif
  exec 'normal A ' . g:TasksAttributeMarker . a:name . l:attVal
endfunc

function! RemoveAttribute(name)
  " if the attribute exists, remove it
  let l:rline = getline('.')
  let l:regex = g:TasksAttributeMarker . a:name . '\(([^)]*)\)\='
  let l:attStart = match(l:rline, regex)
  if l:attStart > -1
    let l:attEnd = matchend(l:rline, l:regex)
    let l:diff = (l:attEnd - l:attStart) + 1
    call cursor(line('.'), l:attStart)
    exec 'normal ' . l:diff . 'dl'
  endif
endfunc

function! GetProjects()
  " read from current line upwards, seeking all project matches
  " and adding them to a list
  let l:lineNr = line('.') - 1
  let l:results = []
  while l:lineNr > 0
    let l:match = matchstr(getline(l:lineNr), s:regProject)
    if len(l:match)
      call add(l:results, Trim(strpart(l:match, 0, len(l:match) - 1)))
      if indent(l:lineNr) == 0
        break
      endif
    endif
    let l:lineNr = l:lineNr - 1
  endwhile
  return reverse(l:results)
endfunc

function! TaskComplete()
  let l:line = getline('.')
  let l:isMatch = match(l:line, s:regMarker)
  let l:doneMatch = match(l:line, s:regDone)
  let l:cancelledMatch = match(l:line, s:regCancelled)

  if l:isMatch > -1
    if l:doneMatch > -1
      " this task is done, so we need to remove the marker and the
      " @done/@project
      call SetLineMarker(g:TasksMarkerBase)
      call RemoveAttribute('done')
      call RemoveAttribute('project')
    else
      if l:cancelledMatch > -1
        " this task was previously cancelled, so we need to swap the marker
        " and just remove the @cancelled first
        call RemoveAttribute('cancelled')
        call RemoveAttribute('project')
      endif
      " swap out the marker, add the @done, find the projects and add @project
      let l:projects = GetProjects()
      call SetLineMarker(g:TasksMarkerDone)
      call AddAttribute('done', strftime(s:dateFormat))
      call AddAttribute('project', join(l:projects, ' / '))
    endif
  endif
endfunc

function! TaskCancel()
  let l:line = getline('.')
  let l:isMatch = match(l:line, s:regMarker)
  let l:doneMatch = match(l:line, s:regDone)
  let l:cancelledMatch = match(l:line, s:regCancelled)

  if l:isMatch > -1
    if l:cancelledMatch > -1
      " this task is done, so we need to remove the marker and the
      " @done/@project
      call SetLineMarker(g:TasksMarkerBase)
      call RemoveAttribute('cancelled')
      call RemoveAttribute('project')
    else
      if l:doneMatch > -1
        " this task was previously cancelled, so we need to swap the marker
        " and just remove the @cancelled first
        call RemoveAttribute('done')
        call RemoveAttribute('project')
      endif
      " swap out the marker, add the @done, find the projects and add @project
      let l:projects = GetProjects()
      call SetLineMarker(g:TasksMarkerCancelled)
      call AddAttribute('cancelled', strftime(s:dateFormat))
      call AddAttribute('project', join(l:projects, ' / '))
    endif
  endif
endfunc

function! TasksArchive()
  " go over every line. Compile a list of all cancelled or completed items
  " until the end of the file is reached or the archive project is
  " detected, whicheved happens first.
  let l:archiveLine = -1
  let l:completedTasks = []
  let l:lineNr = 0
  while l:lineNr < line('$')
    let l:line = getline(l:lineNr)
    let l:doneMatch = match(l:line, s:regDone)
    let l:cancelledMatch = match(l:line, s:regCancelled)
    let l:projectMatch = matchstr(l:line, s:regProject)
    
    if l:doneMatch > -1 || l:cancelledMatch > -1
      call add(l:completedTasks, [l:lineNr, Trim(l:line)])
    endif

    if l:projectMatch > -1 && Trim(l:line) == 'Archive:'
      let l:archiveLine = l:lineNr
      break
    endif

    let l:lineNr = l:lineNr + 1
  endwhile

  if l:archiveLine == -1
    " no archive found yet, so let's stick one in at the very bottom
    exec '%s#\($\n\s*\)\+\%$##'
    exec 'normal Go'
    exec 'normal o' . g:TasksArchiveSeparator
    exec 'normal oArchive:'
    let l:archiveLine = line('.')
  endif

  call cursor(l:archiveLine, 0)

  for [l:lineNr, l:line] in l:completedTasks
    exec 'normal o' . l:line
    if indent(line('.')) == 0
      exec 'normal >>'
    endif
  endfor

  for [l:lineNr, l:line] in reverse(l:completedTasks)
    call cursor(l:lineNr, 0)
    exec 'normal "_dd'
  endfor
endfunc
