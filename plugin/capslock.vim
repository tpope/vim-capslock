" capslock.vim - Software caps lock
" Maintainer:   Tim Pope <https://tpo.pe/>
" Version:      1.1
" GetLatestVimScripts: 1725 1 :AutoInstall: capslock.vim

if exists("g:loaded_capslock") || v:version < 700 || &cp
  finish
endif
let g:loaded_capslock = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1

function! s:enable(mode, ...) abort
  if a:mode == 'i' && exists('##InsertCharPre')
    let b:capslock = 1 + a:0
  else
    let i = char2nr('A')
    while i <= char2nr('Z')
        exe a:mode."noremap <buffer>" nr2char(i) nr2char(i+32)
        exe a:mode."noremap <buffer>" nr2char(i+32) nr2char(i)
        let i = i + 1
    endwhile
  endif
  let &readonly = &readonly
  return ''
endfunction

function! s:disable(mode) abort
  if a:mode == 'i' && exists('##InsertCharPre')
    unlet! b:capslock
  else
    let i = char2nr('A')
    while i <= char2nr('Z')
      silent! exe a:mode."unmap <buffer>" nr2char(i)
      silent! exe a:mode."unmap <buffer>" nr2char(i+32)
      let i = i + 1
    endwhile
  endif
  let &readonly = &readonly
  return ''
endfunction

function! s:toggle(mode, ...) abort
  if s:enabled(a:mode)
    return s:disable(a:mode)
  elseif a:0
    return s:enable(a:mode,a:1)
  else
    return s:enable(a:mode)
  endif
endfunction

function! s:enabled(mode) abort
  if a:mode == 'i' && exists('##InsertCharPre')
    return get(b:, 'capslock', 0)
  else
    return maparg('a',a:mode) == 'A'
  endif
endfunction

function! s:exitcallback() abort
  if s:enabled('i')
    call s:disable('i')
  endif
endfunction

function! CapsLockStatusline() abort
  if mode() == 'c' && s:enabled('c')
    " This won't actually fire because the statusline is apparently not
    " updated in command mode
    return '[(caps)]'
  elseif s:enabled('i')
    return '[caps]'
  else
    return ''
  endif
endfunction

function! CapsLockSTATUSLINE() abort
  if mode() == 'c' && s:enabled('c')
    return ',(CAPS)'
  elseif s:enabled('i')
    return ',CAPS'
  else
    return ''
  endif
endfunction

if exists('##InsertCharPre')
  augroup capslock
    autocmd CursorHold  * call s:exitcallback()
    autocmd InsertLeave * call s:exitcallback()
    autocmd InsertCharPre *
          \ if s:enabled('i') |
          \   let v:char = v:char ==# tolower(v:char) ? toupper(v:char) : tolower(v:char) |
          \ endif
  augroup END
endif

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
