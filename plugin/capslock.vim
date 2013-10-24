" capslock.vim - Software caps lock
" Maintainer:   Tim Pope
" Version:      1.1
" GetLatestVimScripts: 1725 1 :AutoInstall: capslock.vim

if (exists("g:loaded_capslock") && g:loaded_capslock) || v:version < 700 || &cp
  finish
endif
let g:loaded_capslock = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1

function! s:enable(...)
  let b:capslock = 1 + a:0
  return ''
endfunction

function! s:disable()
  unlet! b:capslock
  return ''
endfunction

function! s:toggle(...)
  if s:enabled()
    return s:disable()
  elseif a:0
    return s:enable(a:1)
  else
    return s:enable()
  endif
endfunction

function! s:enabled()
  return get(b:, 'capslock', 0)
endfunction

function! s:exitcallback()
  if get(b:, 'capslock', 0) == 1
    unlet b:capslock
  endif
endfunction

function! CapsLockStatusline()
  return s:enabled() ? '[caps]' : ''
endfunction

function! CapsLockSTATUSLINE()
  return s:enabled() ? ',CAPS' : ''
endfunction

augroup capslock
  autocmd CursorHold  * call s:exitcallback()
  autocmd InsertLeave * call s:exitcallback()
  autocmd InsertCharPre *
        \ if s:enabled() |
        \   let v:char = v:char ==# tolower(v:char) ? toupper(v:char) : tolower(v:char) |
        \ endif
augroup END

" }}}1
" Maps {{{1

noremap  <silent> <Plug>CapsLockToggle  :<C-U>call <SID>toggle('i',1)<CR>
noremap  <silent> <Plug>CapsLockEnable  :<C-U>call <SID>enable('i',1)<CR>
noremap  <silent> <Plug>CapsLockDisable :<C-U>call <SID>disable('i')<CR>
inoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('i')<CR>
inoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('i')<CR>
inoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('i')<CR>
cnoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('c')<CR>
cnoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('c')<CR>
cnoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('c')<CR>
cnoremap <silent>  <SID>CapsLockDisable <C-R>=<SID>disable('c')<CR>

if !hasmapto("<Plug>CapsLockToggle")
  imap <C-G>c <Plug>CapsLockToggle
endif

" }}}1

let &cpo = s:cpo_save

" vim:set sw=2 et:
