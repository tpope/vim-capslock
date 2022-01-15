" capslock.vim - Software caps lock
" Maintainer:   Tim Pope <https://tpo.pe/>
" Version:      1.1
" GetLatestVimScripts: 1725 1 :AutoInstall: capslock.vim

if exists("g:loaded_capslock") || v:version < 704 || &cp
  finish
endif
let g:loaded_capslock = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1

function! s:enable(mode, ...) abort
  if a:mode ==# 'i'
    let b:capslock = 1 + a:0
  endif
  if a:mode ==# 'c'
    let i = char2nr('A')
    while i <= char2nr('Z')
        exe a:mode."noremap <buffer>" nr2char(i) nr2char(i+32)
        exe a:mode."noremap <buffer>" nr2char(i+32) nr2char(i)
        let i = i + 1
    endwhile
  endif
  let &l:readonly = &l:readonly
  return ''
endfunction

function! s:disable(mode) abort
  if a:mode ==# 'i'
    unlet! b:capslock
  endif
  if a:mode ==# 'c'
    let i = char2nr('A')
    while i <= char2nr('Z')
      silent! exe a:mode."unmap <buffer>" nr2char(i)
      silent! exe a:mode."unmap <buffer>" nr2char(i+32)
      let i += 1
    endwhile
  endif
  let &l:readonly = &l:readonly
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
  if a:mode ==# 'i'
    return get(b:, 'capslock', 0)
  else
    return maparg('a', a:mode) ==# 'A'
  endif
endfunction

function! s:exitcallback() abort
  if s:enabled('i') == 1
    call s:disable('i')
  endif
endfunction

function! CapsLockStatusline(...) abort
  return s:enabled('i') ? (a:0 == 1 ? a:1 : '[Caps]') : ''
endfunction

augroup capslock
  autocmd!
  autocmd User Flags call Hoist('window', 'CapsLockStatusline')

  autocmd InsertLeave * call s:exitcallback()
  autocmd InsertCharPre *
        \ if s:enabled('i') |
        \   let v:char = v:char ==# tolower(v:char) ? toupper(v:char) : tolower(v:char) |
        \ endif
augroup END

" }}}1
" Maps {{{1

nnoremap <silent> <Plug>CapsLockToggle  :<C-U>call <SID>toggle('i',1)<CR>
nnoremap <silent> <Plug>CapsLockEnable  :<C-U>call <SID>enable('i',1)<CR>
nnoremap <silent> <Plug>CapsLockDisable :<C-U>call <SID>disable('i')<CR>
inoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('i')<CR>
inoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('i')<CR>
inoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('i')<CR>
cnoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('c')<CR>
cnoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('c')<CR>
cnoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('c')<CR>

if empty(mapcheck("<C-L>", "i")) && exists("*complete_info") && !&insertmode
  function! s:ctrl_l() abort
    let l:compl_mode = complete_info(['mode']).mode
    return l:compl_mode ==# 'ctrl_x' || l:compl_mode ==# 'whole_line' ||
          \ (pumvisible() && complete_info(['selected']).selected !=# -1) ||
          \ &insertmode
          \ ? "\<C-L>" : "\<Plug>CapsLockToggle"
  endfunction
  imap <expr> <C-L> <SID>ctrl_l()
endif
if empty(mapcheck("<C-G>c", "i"))
  imap <C-G>c <Plug>CapsLockToggle
endif
if empty(mapcheck("gC", "n"))
  nmap gC <Plug>CapsLockToggle
endif

" }}}1

let &cpo = s:cpo_save

" vim:set sw=2 et:
