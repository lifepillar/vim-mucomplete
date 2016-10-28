" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#compat#yes_you_can(t)
  return 1
endf

fun! mucomplete#compat#dict(t)
  return strlen(&l:dictionary) > 0
endf

fun! mucomplete#compat#file(t)
  return a:t =~# g:mucomplete#pathsep . '\f*$'
endf

fun! mucomplete#compat#omni(t)
  return strlen(&l:omnifunc) > 0
endf

fun! mucomplete#compat#spel(t)
  return &l:spell && !empty(&l:spelllang)
endf

fun! mucomplete#compat#tags(t)
  return !empty(tagfiles())
endf

fun! mucomplete#compat#thes(t)
  return strlen(&l:thesaurus) > 0
endf

fun! mucomplete#compat#user(t)
  return strlen(&l:completefunc) > 0
endf

fun! mucomplete#compat#ulti(t)
  return get(g:, 'did_plugin_ultisnips', 0)
endf

fun! mucomplete#compat#can_complete()
  return extend({
        \ 'default' : extend({
        \     'dict':  function('mucomplete#compat#dict'),
        \     'file':  function('mucomplete#compat#file'),
        \     'omni':  function('mucomplete#compat#omni'),
        \     'spel':  function('mucomplete#compat#spel'),
        \     'tags':  function('mucomplete#compat#tags'),
        \     'thes':  function('mucomplete#compat#thes'),
        \     'user':  function('mucomplete#compat#user'),
        \     'ulti':  function('mucomplete#compat#ulti')
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
endf

let &cpo = s:save_cpo
unlet s:save_cpo
