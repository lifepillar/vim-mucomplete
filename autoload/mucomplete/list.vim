" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

if exists('*matchstrpos')
  fun! s:getword()
    return matchstrpos(getline('.'), '\S\+\%'.col('.').'c')
  endf
else
  fun! s:getword()
    return [matchstr(getline('.'), '\S\+\%'.col('.').'c'), match(getline('.'), '\S\+\%'.col('.').'c'), 0]
  endf
endif

fun! mucomplete#list#complete() abort
  let [l:word, l:col, l:_] = s:getword()
  let l:suggestions = mucomplete#list#completefunc(0, l:word)
  if !empty(l:suggestions)
    call complete(1 + l:col, l:suggestions)
  endif
  return ''
endf

fun! mucomplete#list#completefunc(findstart, base)
  if a:findstart
    return match(getline('.'), '\S\+\%'.col('.').'c')
  else
    let l:res = []
    " TODO: replace with binary search (and require the list to be sorted)
    for l:m in get(b:, 'mucomplete_wordlist', get(g:, 'mucomplete#wordlist', []))
      if l:m =~ '^' . a:base
        call add(l:res, l:m)
      endif
    endfor
    return l:res
  endif
endfun

let &cpo = s:save_cpo
unlet s:save_cpo

