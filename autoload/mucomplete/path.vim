" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#path#complete() abort
  let l:prefix = matchstr(strpart(getline('.'), 0, col('.') - 1), '\f\%(\f\|\s\)*$')
  while strlen(l:prefix) > 0 " Try to find an existing path (consider paths with spaces, too)
    let l:files = glob(l:prefix.'*', 0, 1, 1)
    if !empty(l:files)
      call complete(col('.') - len(fnamemodify(l:prefix, ":t")), map(l:files,
            \  '{
            \      "word": fnamemodify(v:val, ":t"),
            \      "menu": (isdirectory(v:val) ? "[dir]" : "[file]")
            \   }'
            \ ))
      return ''
    endif
    let l:prefix = matchstr(l:prefix, '\s\zs\f.*$', 1) " Next potential path
  endwhile
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
