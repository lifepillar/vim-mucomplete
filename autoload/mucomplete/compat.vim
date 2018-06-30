" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:pathstart = exists('+shellslash') && !&shellslash
      \ ? (get(g:, 'mucomplete#use_only_windows_paths', 0) ? '[\\~]' : '[/\\~]')
      \ : '[/~]'

fun! mucomplete#compat#yes_you_can(t)
  return 1
endf

fun! mucomplete#compat#default(t)
  return a:t =~# '\m\k\k$' ||
        \ (g:mucomplete_with_key && (get(b:, 'mucomplete_empty_text', get(g:, 'mucomplete#empty_text', 0)) || a:t =~# '\m\k$'))
endf

fun! mucomplete#compat#dict(t)
  return strlen(&l:dictionary) > 0 && (a:t =~# '\m\a\a$' || (g:mucomplete_with_key && a:t =~# '\m\a$'))
endf

fun! mucomplete#compat#file(t)
  return a:t =~# '\m'.s:pathstart.'\f*$'
endf

fun! mucomplete#compat#omni(t)
  return strlen(&l:omnifunc) > 0 && mucomplete#compat#default(a:t)
endf

fun! mucomplete#compat#spel(t)
  return &l:spell && !empty(&l:spelllang) && a:t =~# '\m\a\a\a$'
endf

fun! mucomplete#compat#tags(t)
  return !empty(tagfiles()) && mucomplete#compat#default(a:t)
endf

fun! mucomplete#compat#thes(t)
  return strlen(&l:thesaurus) > 0 && a:t =~# '\m\a\a\a$'
endf

fun! mucomplete#compat#user(t)
  return strlen(&l:completefunc) > 0 && mucomplete#compat#default(a:t)
endf

fun! mucomplete#compat#path(t)
  return a:t =~# '\m'.s:pathstart.'\%(\f\|\s\)*$'
endf

fun! mucomplete#compat#ulti(t)
  return get(g:, 'did_plugin_ultisnips', 0) && mucomplete#compat#default(a:t)
endf

fun! mucomplete#compat#omni_python(t)
  return a:t =~# '\m\k\%(\k\|\.\)$' ||
        \ (g:mucomplete_with_key && (get(b:, 'mucomplete_empty_text', get(g:, 'mucomplete#empty_text', 0)) || a:t =~# '\m\%(\k\|\.\)$'))
endf

fun! mucomplete#compat#can_complete()
  let l:can_complete = extend({
        \ 'default' : extend({
        \     'c-n' :  function('mucomplete#compat#default'),
        \     'c-p' :  function('mucomplete#compat#default'),
        \     'cmd' :  function('mucomplete#compat#default'),
        \     'defs':  function('mucomplete#compat#default'),
        \     'dict':  function('mucomplete#compat#dict'),
        \     'file':  function('mucomplete#compat#file'),
        \     'incl':  function('mucomplete#compat#default'),
        \     'keyn':  function('mucomplete#compat#default'),
        \     'keyp':  function('mucomplete#compat#default'),
        \     'line':  function('mucomplete#compat#default'),
        \     'omni':  function('mucomplete#compat#omni'),
        \     'spel':  function('mucomplete#compat#spel'),
        \     'tags':  function('mucomplete#compat#tags'),
        \     'thes':  function('mucomplete#compat#thes'),
        \     'user':  function('mucomplete#compat#user'),
        \     'path':  function('mucomplete#compat#path'),
        \     'uspl':  function('mucomplete#compat#spel'),
        \     'ulti':  function('mucomplete#compat#ulti')
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {})),
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
  " Special cases
  if has('python') || has('python3')
    call extend(extend(l:can_complete, { 'python': {} }, 'keep')['python'], { 'omni': function('mucomplete#compat#omni_python') }, 'keep')
  endif
  return l:can_complete
endf

let &cpo = s:save_cpo
unlet s:save_cpo
