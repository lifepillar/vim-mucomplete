" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

if has('patch-7.4.654') || (v:version == 704 && has("patch654"))

  fun! s:glob(expr, nosuf, list, alllinks)
    return glob(a:expr, a:nosuf, a:list, a:alllinks)
  endf

elseif v:version > 703 || (v:version == 703 && has("patch465"))

  fun! s:glob(expr, nosuf, list, alllinks)
    return glob(a:expr, a:nosuf, a:list)
  endf

else

  fun! s:glob(expr, nosuf, list, alllinks)
    return split(glob(a:expr, a:nosuf), "\n")
  endf

endif

let s:pathstart = exists('+shellslash') && !&shellslash
      \ ? (get(g:, 'mucomplete#use_only_windows_paths', 0) ? '^[\\~]' : '^[/\\~]')
      \ : '^[/~]'
if exists('&fileignorecase')

  fun! s:case_insensitive()
    return &fileignorecase || &wildignorecase
  endf

elseif exists('&wildignorecase')

  fun! s:case_insensitive()
    return &wildignorecase
  endf

else

  fun! s:case_insensitive()
    return 1
  endf

endif

fun! mucomplete#path#complete() abort
  let l:prefix = matchstr(getline('.'), '\f\%(\f\|\s\)*\%'.col('.').'c')
  let l:case_insensitive = s:case_insensitive()
  while strlen(l:prefix) > 0 " Try to find an existing path (consider paths with spaces, too)
    if l:prefix ==# '~'
      let l:files = s:glob('~', 0, 1, 1)
      if !empty(l:files)
        call complete(col('.') - 1, map(l:files, '{ "word": v:val, "menu": "[dir]", "icase": l:case_insensitive }'))
      endif
      return ''
    else
      let l:files = s:glob((get(g:, 'mucomplete#buffer_relative_paths', 0)
            \    && l:prefix !~# s:pathstart ? expand('%:p:h').'/' : '') . l:prefix . '*', 0, 1, 1)
      if !empty(l:files)
        call complete(col('.') - len(fnamemodify(l:prefix, ":t")), map(l:files,
              \  '{
              \      "word": fnamemodify(v:val, ":t"),
              \      "menu": (isdirectory(v:val) ? "[dir]" : "[file]"),
              \      "icase": l:case_insensitive
              \   }'
              \ ))
        return ''
      endif
    endif
    let l:prefix = matchstr(l:prefix, '\s\zs\f.*$', 1) " Next potential path
  endwhile
  return ''
endf

let &cpo = s:save_cpo
unlet s:save_cpo
