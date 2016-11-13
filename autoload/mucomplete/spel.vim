" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:suggestions = ''

fun! mucomplete#spel#gather() abort
  redir => s:suggestions
  silent normal! z=
  redir END
endf

fun! mucomplete#spel#complete() abort
  let l:col = 1 + match(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  let l:suggestions = map(filter(split(s:suggestions, "\n"), 'v:val =~# "\\m^\\s*\\d"'), "matchstr(v:val, '\"\\zs.\\+\\ze\"')")
  if !empty(l:suggestions)
    call complete(l:col, l:suggestions)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
