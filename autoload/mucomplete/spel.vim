" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#spel#complete() abort
  let l:col         = 1 + match(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  let l:word        = get(g:, 'mucomplete#spel#good_words', 0)
                    \ ? matchstr(getline('.'), '\S\+\%'.col('.').'c')
                    \ : spellbadword(matchstr(getline('.'), '\S\+\%'.col('.').'c'))[0]
  let l:suggestions = !empty(l:word)
                    \ ? spellsuggest(l:word, get(g:, 'mucomplete#spel#max', 25))
                    \ : []

  if !empty(l:suggestions)
    call complete(l:col, l:suggestions)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
