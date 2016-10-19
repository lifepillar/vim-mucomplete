" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

let g:mucomplete#chains = extend(get(g:, 'mucomplete#chains', {}), {
      \ 'default' : ['file', 'omni', 'keyn', 'dict']
      \ }, 'keep')

" Conditions to be verified for a given method to be applied.
let g:mucomplete#can_complete = {
      \ 'default' : {
      \     'dict':  { t -> strlen(&l:dictionary) > 0 },
      \     'file':  { t -> t =~# '/' },
      \     'omni':  { t -> strlen(&l:omnifunc) > 0 },
      \     'spel':  { t -> &l:spell },
      \     'tags':  { t -> !empty(tagfiles()) },
      \     'thes':  { t -> strlen(&l:thesaurus) > 0 },
      \     'user':  { t -> strlen(&l:completefunc) > 0 }
      \   }
      \ }

" Note: In 'c-n' and 'c-p' below we use the fact that pressing <c-x> while in
" ctrl-x submode doesn't do anything and any key that is not valid in ctrl-x
" submode silently ends that mode (:h complete_CTRL-Y) and inserts the key.
" Hence, after <c-x><c-b>, we are surely out of ctrl-x submode. The subsequent
" <bs> is used to delete the inserted <c-b>. We use <c-b> because it is not
" mapped (:h i_CTRL-B-gone). This trick is needed to have <c-p> trigger
" keyword completion under all circumstances, in particular when the current
" mode is the ctrl-x submode. (pressing <c-p>, say, immediately after
" <c-x><c-o> would do a different thing).
let g:mucomplete#exit_ctrlx_key = "\<c-b>"

fun! mucomplete#enable_autocompletion()
  let s:completedone = 0
  let g:mucomplete#mappings = {
        \ 'c-n'     :  "\<c-x>".g:mucomplete#exit_ctrlx_key."\<bs>\<c-n>\<c-p>",
        \ 'c-p'     :  "\<c-x>".g:mucomplete#exit_ctrlx_key."\<bs>\<c-p>\<c-n>",
        \ 'cmd'     :  "\<c-x>\<c-v>\<c-p>",
        \ 'defs'    :  "\<c-x>\<c-d>\<c-p>",
        \ 'dict'    :  "\<c-x>\<c-k>\<c-p>",
        \ 'file'    :  "\<c-x>\<c-f>\<c-p>",
        \ 'incl'    :  "\<c-x>\<c-i>\<c-p>",
        \ 'keyn'    :  "\<c-x>\<c-n>\<c-p>",
        \ 'keyp'    :  "\<c-x>\<c-p>\<c-n>",
        \ 'line'    :  "\<c-x>\<c-l>\<c-p>",
        \ 'omni'    :  "\<c-x>\<c-o>\<c-p>",
        \ 'spel'    :  "\<c-x>s\<c-p>",
        \ 'tags'    :  "\<c-x>\<c-]>\<c-p>",
        \ 'thes'    :  "\<c-x>\<c-t>\<c-p>",
        \ 'user'    :  "\<c-x>\<c-u>\<c-p>"
        \ }
  augroup mucomplete_auto
    autocmd!
    autocmd TextChangedI * noautocmd if s:completedone | let s:completedone = 0 | else | silent call mucomplete#autocomplete() | endif
    autocmd CompleteDone * noautocmd let s:completedone = 1
  augroup END
endf

fun! mucomplete#disable_autocompletion()
  if exists('#mucomplete_auto')
    autocmd! mucomplete_auto
    augroup! mucomplete_auto
  endif
  let g:mucomplete#mappings = {
        \ 'c-n'     :  "\<c-x>".g:mucomplete#exit_ctrlx_key."\<bs>\<c-n>",
        \ 'c-p'     :  "\<c-x>".g:mucomplete#exit_ctrlx_key."\<bs>\<c-p>",
        \ 'cmd'     :  "\<c-x>\<c-v>",
        \ 'defs'    :  "\<c-x>\<c-d>",
        \ 'dict'    :  "\<c-x>\<c-k>",
        \ 'file'    :  "\<c-x>\<c-f>",
        \ 'incl'    :  "\<c-x>\<c-i>",
        \ 'line'    :  "\<c-x>\<c-l>",
        \ 'keyn'    :  "\<c-x>\<c-n>",
        \ 'keyp'    :  "\<c-x>\<c-p>",
        \ 'omni'    :  "\<c-x>\<c-o>",
        \ 'spel'    :  "\<c-x>s",
        \ 'tags'    :  "\<c-x>\<c-]>",
        \ 'thes'    :  "\<c-x>\<c-t>",
        \ 'user'    :  "\<c-x>\<c-u>"
        \ }
  if exists('s:completedone')
    unlet s:completedone
  endif
endf

if get(g:, 'mucomplete_auto', 0)
   call mucomplete#enable_autocompletion()
else
   call mucomplete#disable_autocompletion()
endif

" Internal status
let s:compl_methods = []
let s:compl_text = ''

" Workhorse function for chained completion. Do not call directly.
fun! mucomplete#complete_chain(index)
  let i = a:index
  while i < len(s:compl_methods) &&
        \ !get(get(g:mucomplete#can_complete, getbufvar("%","&ft"), {}),
        \          s:compl_methods[i],
        \          get(g:mucomplete#can_complete['default'], s:compl_methods[i], { t -> 1 })
        \ )(s:compl_text)
    let i += 1
  endwhile
  if i < len(s:compl_methods)
    return g:mucomplete#mappings[s:compl_methods[i]] .
          \ "\<c-r>=pumvisible()?'':mucomplete#complete_chain(".(i+1).")\<cr>"
  endif
  return ''
endf

fun! s:complete(dir)
  let s:compl_methods = get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default'])
  if a:dir == -1
    call reverse(s:compl_methods)
  endif
  return mucomplete#complete_chain(0)
endf

fun! mucomplete#complete(dir)
  if pumvisible()
    return a:dir == -1 ? "\<c-p>" : "\<c-n>"
  endif
  let s:compl_text = matchstr(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  return strlen(s:compl_text) == 0
        \ ? (a:dir == -1 ? "\<c-d>" : "\<tab>")
        \ : get(b:, 'lf_tab_complete', s:complete(a:dir))
endf


fun! mucomplete#autocomplete()
  if match(strpart(getline('.'), 0, col('.') - 1), '\k\k$') > -1
    silent call feedkeys("\<tab>", 'i')
  endif
endf

let &cpo = s:save_cpo
unlet s:save_cpo
