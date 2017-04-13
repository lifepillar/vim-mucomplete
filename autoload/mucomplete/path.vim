" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

if v:version > 703 || v:version == 703 && has("patch465")

  fun! mucomplete#path#complete() abort
    let l:prefix = matchstr(getline('.'), '\f\%(\f\|\s\)*\%'.col('.').'c')
    while strlen(l:prefix) > 0 " Try to find an existing path (consider paths with spaces, too)
      if l:prefix ==# '~'
        let l:prefix = glob('~', 0, 1, 1)
        if !empty(l:prefix)
          call complete(col('.') - 1, map(l:prefix, '{ "word": v:val, "menu": "[dir]" }'))
        endif
        return ''
      else " FIXME: only Unix-like relative paths
        let l:files = glob((get(g:, 'mucomplete#buffer_relative_paths', 0) && l:prefix !~# '^[/~]' ? expand('%:p:h').'/' : '') . l:prefix . '*', 0, 1, 1)
        if !empty(l:files)
          call complete(col('.') - len(fnamemodify(l:prefix, ":t")), map(l:files,
                \  '{
                \      "word": fnamemodify(v:val, ":t"),
                \      "menu": (isdirectory(v:val) ? "[dir]" : "[file]")
                \   }'
                \ ))
          return ''
        endif
      endif
      let l:prefix = matchstr(l:prefix, '\s\zs\f.*$', 1) " Next potential path
    endwhile
    return ''
  endf

else

  echoerr "'path' completion is not supported with this Vim version."

  fun! mucomplete#path#complete() abort
    return ''
  endf

endif

let &cpo = s:save_cpo
unlet s:save_cpo
