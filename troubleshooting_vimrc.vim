" vim: foldmethod=marker foldenable
" Do not change this section {{{
set nocompatible
set nobackup noswapfile
if has('persistent_undo')
  set noundofile
endif
if has('writebackup')
  set nowritebackup
endif
if has('viminfo')
  set viminfo=""
endif
if has('packages')
  set packpath=
endif
set completeopt=menuone
if has('patch-7.4.775')
  if !has('patch-7.4.784')
    echomsg "WARNING: noinsert and noselect may not work properly with this version of Vim."
  endif
  set completeopt+=noinsert
else
  echomsg "Automatic completion is not available in this version of Vim."
endif
set showmode
if has('patch-7.4.314')
  set shortmess-=c
endif
set runtimepath=
" }}}

set runtimepath+=~/.vim  " Remove this line unless you need it for finding spell files or other data
set runtimepath+=/path/to/mucomplete/  " CHANGE THIS

" Optionally add additional configuration below this line
