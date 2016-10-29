" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:hat = get(g:, 'mucomplete#ultisnips#match_at_start', 1) ? '^' : ''

fun! mucomplete#ultisnips#complete() abort
  if empty(UltiSnips#SnippetsInCurrentScope(1))
    return ''
  endif
  let l:pat = s:hat . matchstr(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  let l:candidates = map(filter(keys(g:current_ulti_dict_info), 'v:val =~ l:pat'),
        \  '{
        \      "word": v:val,
        \      "menu": "[snip] ". get(g:current_ulti_dict_info[v:val], "description", ""),
        \      "dup" : 1
        \   }')
  if !empty(l:candidates)
    call complete(col('.') - len(l:pat) + len(s:hat), l:candidates)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
