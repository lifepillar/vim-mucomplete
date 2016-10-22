" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

if exists("g:loaded_mucomplete")
  finish
endif
let g:loaded_mucomplete = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists(":MUcompleteAutoOn")
  command -nargs=? -complete=dir MUcompleteAutoOn :call mucomplete#enable_auto(<q-args>)
endif

if !exists(":MUcompleteAutoOff")
  command -nargs=0 MUcompleteAutoOff :call mucomplete#disable_auto()
endif

imap <expr> <silent> <plug>(MUcompleteNxt) mucomplete#complete_chain()
imap <expr> <silent> <plug>(MUcompleteFwd) mucomplete#complete(0)
imap <expr> <silent> <plug>(MUcompleteBwd) mucomplete#complete(1)
inoremap    <silent> <plug>(MUcompleteTab) <tab>
inoremap    <silent> <plug>(MUcompleteCtd) <c-d>

if !get(g:, 'mucomplete#no_mappings', 0)
  if !hasmapto('<plug>(MUcompleteFwd)', 'i')
    imap <tab>   <plug>(MUcompleteFwd)
  endif
  if !hasmapto('<plug>(MUcompleteBwd)', 'i')
    imap <s-tab> <plug>(MUcompleteBwd)
  endif

  inoremap <expr> <cr> pumvisible() ? "\<c-y>\<cr>" : "\<cr>"
endif

if get(g:, 'mucomplete#enable_auto_at_startup', 0)
  MUcompleteAutoOn
endif

let &cpo = s:save_cpo
unlet s:save_cpo
