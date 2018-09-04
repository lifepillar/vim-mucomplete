" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#auto#enable()
  augroup MUcompleteAuto
    autocmd!
    autocmd InsertCharPre * noautocmd call mucomplete#auto#insertcharpre()
    if get(g:, 'mucomplete#completion_delay', 0) > 1 && has('timers')
      autocmd TextChangedI * noautocmd call <sid>start_timer()
      autocmd  InsertLeave * noautocmd call <sid>stop_timer()
    elseif get(g:, 'mucomplete#completion_delay', 0)
      autocmd TextChangedI * noautocmd call mucomplete#auto#ic_auto_complete()
      autocmd  CursorHoldI * noautocmd call mucomplete#auto#auto_complete()
    else
      autocmd TextChangedI * noautocmd call mucomplete#auto#auto_complete()
    endif
  augroup END
endf

fun! mucomplete#auto#disable()
  if exists('#MUcompleteAuto')
    autocmd! MUcompleteAuto
    augroup! MUcompleteAuto
  endif
endf

fun! mucomplete#auto#toggle()
  if exists('#MUcompleteAuto')
    call mucomplete#auto#disable()
    echomsg '[MUcomplete] Auto off'
  else
    call mucomplete#auto#enable()
    echomsg '[MUcomplete] Auto on'
  endif
endf

fun! s:start_timer()
  if exists('s:completion_timer')
    call timer_stop(s:completion_timer)
  endif
  let s:completion_timer = timer_start(get(g:, 'mucomplete#completion_delay', 150), 'mucomplete#auto#timer_complete')
endf

fun! s:stop_timer()
  if exists('s:completion_timer')
    call timer_stop(s:completion_timer)
    unlet s:completion_timer
  endif
endf

fun! mucomplete#auto#timer_complete(tid)
  unlet s:completion_timer
  if !pumvisible()
    call mucomplete#auto#auto_complete()
  endif
endf

if has('patch-8.0.0283')
  let s:insertcharpre = 0

  fun! mucomplete#auto#insertcharpre()
    let s:insertcharpre = !pumvisible() && (v:char =~# '\m\S')
  endf

  fun! mucomplete#auto#ic_auto_complete()
    if mode(1) ==# 'ic'  " In Insert completion mode, CursorHoldI in not invoked
      call mucomplete#auto_complete()
    endif
  endf

  fun! mucomplete#auto#auto_complete()
    if s:insertcharpre || mode(1) ==# 'ic'
      let s:insertcharpre = 0
      call mucomplete#auto_complete()
    endif
  endf

  let &cpo = s:save_cpo
  unlet s:save_cpo

  finish
endif

" Code for Vim 8.0.0282 and older
if !(get(g:, 'mucomplete#no_popup_mappings', 0) || get(g:, 'mucomplete#no_mappings', 0) || get(g:, 'no_plugin_maps', 0))
  if !hasmapto('<plug>(MUcompletePopupCancel)', 'i')
    call mucomplete#map('imap', '<c-e>', '<plug>(MUcompletePopupCancel)')
  endif
  if !hasmapto('<plug>(MUcompletePopupAccept)', 'i')
    call mucomplete#map('imap', '<c-y>', '<plug>(MUcompletePopupAccept)')
  endif
  if !hasmapto('<plug>(MUcompleteCR)', 'i')
    call mucomplete#map('imap', '<cr>', '<plug>(MUcompleteCR)')
  endif
endif

let s:cancel_auto = 0
let s:insertcharpre = 0

fun! mucomplete#auto#popup_exit(keys)
  let s:cancel_auto = pumvisible()
  return a:keys
endf

fun! mucomplete#auto#insertcharpre()
  let s:insertcharpre = (v:char =~# '\m\S')
endf

fun! mucomplete#auto#ic_auto_complete()
  if s:cancel_auto
    let s:cancel_auto = 0
    return
  endif
  if !s:insertcharpre
    call mucomplete#auto_complete()
  endif
endf

fun! mucomplete#auto#auto_complete()
  if s:cancel_auto
    let [s:cancel_auto, s:insertcharpre] = [0,0]
    return
  endif
  if s:insertcharpre
    let s:insertcharpre = 0
    call mucomplete#auto_complete()
  endif
endf

let &cpo = s:save_cpo
unlet s:save_cpo

