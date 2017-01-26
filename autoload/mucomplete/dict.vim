" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:cmp = 'stridx(v:val, l:word)' . (get(g:, 'mucomplete#dict#match_at_start', 1) ? '==0' : '>=0')

if exists('*matchstrpos')
  fun! s:getword()
    return matchstrpos(getline('.'), '\S\+\%'.col('.').'c')
  endf
else
  fun! s:getword()
    return [matchstr(getline('.'), '\S\+\%'.col('.').'c'), match(getline('.'), '\S\+\%'.col('.').'c'), 0]
  endf
endif

fun! mucomplete#dict#complete() abort
  let [l:word, l:col, l:_] = s:getword()

  let l:suggestions = []
  for l:list in map(map(split(&l:dictionary, '\m\\\@<!,'), 'substitute(v:val, "\\", "", "g")'), "readfile(v:val)")
      call extend(l:suggestions, l:list)
  endfor

  call filter(l:suggestions, s:cmp)

  if !empty(l:suggestions)
    call complete(1 + l:col, l:suggestions)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
