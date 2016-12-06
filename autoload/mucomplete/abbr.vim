" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let s:abbrev = map(reverse(split(execute('iabbrev'), "\n")), '{
      \ "lhs" : matchstr(v:val, "\\mi\\s\\+\\zs\\k\\+"),
      \ "rhs" : matchstr(v:val, "\\m\\*\\s\\+\\zs.*"),
      \ }')

fun! mucomplete#abbr#complete() abort
  let l:word = matchstr(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  let l:abbrev = map(filter(copy(s:abbrev), 'stridx(v:val.lhs, l:word) == 0'),
        \ '{ "word" : v:val.lhs,
        \    "menu" : v:val.rhs,
        \ }')
  if !empty(l:abbrev)
    call complete(col('.') - len(l:word), l:abbrev)
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
