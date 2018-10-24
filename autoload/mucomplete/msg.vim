" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! s:show_current_method()
  unsilent echo '[MUcomplete]' get(g:mucomplete#msg#methods, get(g:, 'mucomplete_current_method', ''), 'Custom method')
  " Force placing the cursor back into the buffer
  " Without this, the cursor may get stuck in the command line after the
  " message is printed until another character is typed.
  " Note: this works only if the status line is visible!
  let &ro=&ro
endf

fun! s:show_current_method_short()
  unsilent echo '[MUcomplete]' get(g:mucomplete#msg#short_methods, get(g:, 'mucomplete_current_method', ''), 'Custom method')
  let &ro=&ro
endf

fun! s:retrieve_method()
  let g:mucomplete_method = get(g:, 'mucomplete_current_method', '')
  let &ro=&ro  " Force redrawing the status line
endf

fun! s:prepare_for_status_line()
  augroup MUcompleteNotifications
    autocmd!
    autocmd User MUcompletePmenu call s:retrieve_method()
    autocmd CompleteDone * let g:mucomplete_method = '' | let &ro=&ro
  augroup END
endf

fun! s:be_verbose(n)
  augroup MUcompleteNotifications
    autocmd!
    if a:n == 1
      autocmd User MUcompletePmenu call s:show_current_method_short()
    else
      autocmd User MUcompletePmenu call s:show_current_method()
    endif
    " Clear messages when the popup menu is dismissed:
    autocmd CompleteDone * echo "\r"
  augroup END
endf

fun! s:dont_be_verbose()
  if exists('#MUcompleteNotifications')
    autocmd! MUcompleteNotifications
    augroup! MUcompleteNotifications
  endif
endf

fun! mucomplete#msg#set_notifications(n)
  if a:n == 3
    call s:prepare_for_status_line()
  elseif a:n > 0
    call s:be_verbose(a:n)
  else
    call s:dont_be_verbose()
  endif
endf

let g:mucomplete#msg#methods = extend({
      \ "c-n" : "Keywords in 'complete' (search forwards)",
      \ "c-p" : "Keywords in 'complete' (search backwards)",
      \ "cmd" : "Vim commands",
      \ "defs": "Definitions or macros",
      \ "dict": "Keywords in 'dictionary'",
      \ "file": "File completion",
      \ "incl": "Keywords in the current and included files",
      \ "keyn": "Keywords in the current file (search forwards)",
      \ "keyp": "Keywords in the current file (search backwards)",
      \ "line": "Whole lines",
      \ "nsnp": "Neosnippet snippets",
      \ "omni": "Omni completion ('omnifunc')",
      \ "path": "Path completion",
      \ "snip": "SnipMate snippets",
      \ "spel": "Spelling suggestions",
      \ "tags": "Tags completion",
      \ "thes": "Keywords in 'thesaurus'",
      \ "user": "User defined completion ('completefunc')",
      \ "ulti": "Ultisnips snippets",
      \ "uspl": "Improved spelling suggestions",
      \ }, get(g:, 'mucomplete#msg#methods', {}))

let g:mucomplete#msg#short_methods = extend({
      \ "c-n" : "keywords",
      \ "c-p" : "keywords",
      \ "cmd" : "vim",
      \ "defs": "definitions",
      \ "dict": "dictionary",
      \ "file": "files",
      \ "incl": "included files",
      \ "keyn": "buffer keywords",
      \ "keyp": "buffer keywords",
      \ "line": "whole lines",
      \ "nsnp": "neosnippet",
      \ "omni": "omnifunc",
      \ "path": "paths",
      \ "snip": "snipmate",
      \ "spel": "spelling",
      \ "tags": "tags",
      \ "thes": "thesaurus",
      \ "user": "completefunc",
      \ "ulti": "ultisnips",
      \ "uspl": "spelling",
      \ }, get(g:, 'mucomplete#msg#short_methods', {}))

let &cpo = s:save_cpo
unlet s:save_cpo

