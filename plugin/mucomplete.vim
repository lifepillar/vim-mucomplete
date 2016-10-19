" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

if exists("g:loaded_mucomplete")
  finish
endif
let g:loaded_mucomplete = 1

let s:save_cpo = &cpo
set cpo&vim

fun! s:mucomplete_enable_auto()
  let g:mucomplete#_auto_ = 1
  let s:completedone = 0
  augroup MucompleteAuto
    autocmd!
    autocmd TextChangedI * noautocmd if s:completedone | let s:completedone = 0 | else | silent call mucomplete#autocomplete() | endif
    autocmd CompleteDone * noautocmd let s:completedone = 1
  augroup END
endf

fun! s:mucomplete_disable_auto()
  if exists('#MucompleteAuto')
    autocmd! MucompleteAuto
    augroup! MucompleteAuto
  endif
  if exists('s:completedone')
    unlet s:completedone
  endif
  let g:mucomplete#_auto_ = 0
endf

if !exists(":MucompleteAutoOn")
  command -nargs=0 MucompleteAutoOn :call <sid>mucomplete_enable_auto()
endif

if !exists(":MucompleteAutoOff")
  command -nargs=0 MucompleteAutoOff :call <sid>mucomplete_disable_auto()
endif

let g:mucomplete#_auto_ = 0

imap <expr> <silent> <tab>   mucomplete#complete(0)
imap <expr> <silent> <s-tab> mucomplete#complete(1)

let &cpo = s:save_cpo
unlet s:save_cpo
