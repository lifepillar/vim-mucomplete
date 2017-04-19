" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:pathsep = exists('+shellslash') && !&shellslash ? '\\' : '/'

fun! mucomplete#compat#yes_you_can(t)
  return 1
endf

fun! mucomplete#compat#default(t)
  return g:mucomplete_with_key || a:t =~# '\m\k\k$'
endf

fun! mucomplete#compat#dict(t)
  return strlen(&l:dictionary) > 0 && (g:mucomplete_with_key || a:t =~# '\m\a\a$')
endf

fun! mucomplete#compat#omni(t)
  return strlen(&l:omnifunc) > 0 && (g:mucomplete_with_key || a:t =~# '\m\k\k$')
endf

fun! mucomplete#compat#spel(t)
  return &l:spell && !empty(&l:spelllang) && a:t =~# '\m\a\a\a$'
endf

fun! mucomplete#compat#tags(t)
  return !empty(tagfiles()) && (g:mucomplete_with_key || a:t =~# '\m\k\k$')
endf

fun! mucomplete#compat#thes(t)
  return strlen(&l:thesaurus) > 0 && a:t =~# '\m\a\a\a$'
endf

fun! mucomplete#compat#user(t)
  return strlen(&l:completefunc) > 0 && (g:mucomplete_with_key || a:t =~# '\m\k\k$')
endf

fun! mucomplete#compat#path(t)
  return a:t =~# '\m\%('.s:pathsep.'\|\~\)\f*$'
endf

fun! mucomplete#compat#ulti(t)
  return get(g:, 'did_plugin_ultisnips', 0) && (g:mucomplete_with_key || a:t =~# '\m\k\k$')
endf

fun! mucomplete#compat#can_complete()
  return extend({
        \ 'default' : extend({
        \     'c-n' :  function('mucomplete#compat#default'),
        \     'c-p' :  function('mucomplete#compat#default'),
        \     'cmd' :  function('mucomplete#compat#default'),
        \     'defs':  function('mucomplete#compat#default'),
        \     'dict':  function('mucomplete#compat#dict'),
        \     'file':  function('mucomplete#compat#path'),
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
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
endf

let &cpo = s:save_cpo
unlet s:save_cpo
