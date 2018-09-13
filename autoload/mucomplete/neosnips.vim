" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:cmp = 'stridx(v:val, l:pat)' . (get(g:, 'mucomplete#neosnippet#match_at_start', 1) ? '==0' : '>=0')

fun! mucomplete#neosnips#complete() abort
  let l:snippets = neosnippet#helpers#get_completion_snippets()
  if empty(l:snippets)
    return ''
  endif
  let l:pat = matchstr(getline('.'), '\S\+\%'.col('.').'c')
  let l:candidates = map(filter(keys(l:snippets), s:cmp),
        \  '{
        \      "word": l:snippets[v:val]["word"],
        \      "menu": "[neosnippet] ". get(l:snippets[v:val], "menu_abbr", ""),
        \      "dup" : 1
        \   }')
  if !empty(l:candidates)
    call complete(col('.') - len(l:pat), l:candidates)
  endif
  return ''
endf


" Automatic expansion of snippets

fun! mucomplete#neosnips#do_expand(keys)
  if get(v:completed_item, 'menu', '') =~# '[neosnippet]'
    return neosnippet#expand(v:completed_item['word'])
  endif
  return a:keys
endf

fun! mucomplete#neosnips#expand_snippet(keys)
  return pumvisible()
        \ ? "\<c-y>\<c-r>=mucomplete#neosnips#do_expand('')\<cr>"
        \ : a:keys
endf

let &cpo = s:save_cpo
unlet s:save_cpo


