" capslock.vim - Software caps lock
" Maintainer:   Tim Pope
" Version:      1.1
" GetLatestVimScripts: 1725 1 :AutoInstall: capslock.vim

if (exists("g:loaded_capslock") && g:loaded_capslock) || &cp
    finish
endif
let g:loaded_capslock = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1

" Uses for this should be rare, but if you :let the following variable, caps
" lock state should be tracked globally.  Largely untested, let me know if you
" have problems.
if exists('g:capslock_global')
    let s:buffer = ''
else
    let s:buffer = '<buffer>'
endif

function! s:initsettings()
    let l:capslock_key_mapping_default = {}
    for i in range(char2nr('a'), char2nr('z'))
        let l:capslock_key_mapping_default[nr2char(i)] = nr2char(i-32)
    endfor
    let g:capslock_key_mapping = get(g:, 'capslock_key_mapping', {})
    call extend(g:capslock_key_mapping, l:capslock_key_mapping_default, 'keep')
endfunction

function! s:enable(mode,...)
    for item in items(get(g:, 'capslock_key_mapping', {}))
        exe a:mode.'noremap' s:buffer item[0] item[1]
        exe a:mode.'noremap' s:buffer item[1] item[0]
    endfor
    if a:0 && a:1
        if exists('g:capslock_global')
            let g:capslock_persist = 1
        else
            let b:capslock_persist = 1
        endif
    endif
    return ""
endfunction

function! s:disable(mode)
    if s:enabled(a:mode)
        for item in keys(get(g:, 'capslock_custom_mapping', {}))
            silent! exe a:mode.'unmap' s:buffer item[0]
            silent! exe a:mode.'unmap' s:buffer item[1]
        endfor
    endif
    unlet! b:capslock_persist
    if exists('g:capslock_global')
        unlet! g:capslock_persist
    endif
    return ""
endfunction

function! s:toggle(mode,...)
    if s:enabled(a:mode)
        call s:disable(a:mode)
    else
        if a:0
            call s:enable(a:mode,a:1)
        else
            call s:enable(a:mode)
        endif
    endif
    return ""
endfunction

function! s:enabled(mode)
    return maparg('a',a:mode) == 'A'
endfunction

function! s:exitcallback()
    if !exists('g:capslock_persist') && !exists('b:capslock_persist') && s:enabled('i')
        call s:disable('i')
    endif
endfunction

function! CapsLockStatusline()
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

function! CapsLockSTATUSLINE()
    if mode() == 'c' && s:enabled('c')
        return ',(CAPS)'
    elseif s:enabled('i')
        return ',CAPS'
    else
        return ''
    endif
endfunction

augroup capslock
    autocmd VimEnter * call s:initsettings()
    if v:version >= 700
        autocmd InsertLeave * call s:exitcallback()
    endif
    autocmd CursorHold  * call s:exitcallback()
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

" Enable g:capslock_command_mode if you want capslock.vim to attempt to
" disable command mode caps lock after each :command.  This is hard to trap
" elegantly so it is disabled by default.  If you use this, you still must
" provide your own command mode mapping.
if exists('g:capslock_command_mode')
    map  <script> :    :<SID>CapsLockDisable
    map  <script> /    /<SID>CapsLockDisable
    map  <script> ?    ?<SID>CapsLockDisable
endif

" }}}1

let &cpo = s:cpo_save

" vim:set ft=vim ff=unix ts=8 sw=4 sts=4:
