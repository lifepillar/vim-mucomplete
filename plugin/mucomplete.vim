" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

if exists("g:loaded_mucomplete")
  finish
endif
let g:loaded_mucomplete = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists(":EnableAutocompletion")
  command -nargs=0 EnableAutocompletion :call mucomplete#EnableAutocompletion()
endif

if !exists(":DisableAutocompletion")
  command -nargs=0 DisableAutocompletion :call mucomplete#DisableAutocompletion()
endif

inoremap <expr><silent> <tab>   mucomplete#complete(1)
inoremap <expr><silent> <s-tab> mucomplete#complete(-1)

let &cpo = s:save_cpo
unlet s:save_cpo
