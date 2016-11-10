" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#path#complete() abort
  let l:prefix = matchstr(strpart(getline('.'), 0, col('.') - 1), '\f\+$')
  if strlen(l:prefix) > 0
    let l:candidates = map(glob(l:prefix.'*', 0, 1, 1),
          \  '{
          \      "word": fnamemodify(v:val, ":t"),
          \      "menu": (isdirectory(v:val) ? "[dir]" : "[file]")
          \   }')
    if !empty(l:candidates)
      call complete(col('.') - len(fnamemodify(l:prefix, ":t")), l:candidates)
    endif
  endif
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
