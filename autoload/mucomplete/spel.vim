" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#spel#complete() abort
  let [l:word, l:col, l:_] = matchstrpos(getline('.'), '\S\+\%'.col('.').'c')
  let l:suggestions = spellsuggest(
        \               get(g:, 'mucomplete#spel#good_words', 0)
        \               ? l:word
        \               : spellbadword(l:word, get(g:, 'mucomplete#spel#max', 25))[0]
        \               )
  if !empty(l:suggestions)
    call complete(1 + l:col, l:suggestions)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
