" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#spel#complete() abort
  let l:word        = matchstr(getline('.'), '\S\+\%'.col('.').'c')
  let l:badword     = spellbadword(l:word)
  let l:suggestions = !empty(l:badword[1])
                    \ ? spellsuggest(l:badword[0])
                    \ : []

  if !empty(l:suggestions)
    call complete(col('.') - len(l:word), l:suggestions)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
