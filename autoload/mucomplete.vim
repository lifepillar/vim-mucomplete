" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

fun! mucomplete#enable_auto(...)
  let s:completedone = 0
  augroup MUcompleteAuto
    autocmd!
    execute 'autocmd TextChangedI' (strlen(a:000[0]) > 0 ? a:1 : '*')
          \ 'noautocmd if s:completedone | let s:completedone = 0 | else | silent call mucomplete#autocomplete() | endif'
    execute 'autocmd CompleteDone' (strlen(a:000[0]) > 0 ? a:1 : '*')
          \ 'noautocmd let s:completedone = 1'
  augroup END
endf

fun! mucomplete#disable_auto()
  if exists('#MUcompleteAuto')
    autocmd! MUcompleteAuto
    augroup! MUcompleteAuto
  endif
  if exists('s:completedone')
    unlet s:completedone
  endif
endf

" Patterns to decide when automatic completion should be triggered.
let g:mucomplete#trigger_auto_pattern = extend({
      \ 'default' : '\k\k$'
      \ }, get(g:, 'mucomplete#trigger_auto_pattern', {}))

" Completion chains
let g:mucomplete#chains = extend({
      \ 'default' : ['file', 'omni', 'keyn', 'dict']
      \ }, get(g:, 'mucomplete#chains', {}))

" Conditions to be verified for a given method to be applied.
let s:yes_you_can = { _ -> 1 } " Try always
let g:mucomplete#can_complete = extend({
      \ 'default' : extend({
      \     'dict':  { t -> strlen(&l:dictionary) > 0 },
      \     'file':  { t -> t =~# '/' },
      \     'omni':  { t -> strlen(&l:omnifunc) > 0 },
      \     'spel':  { t -> &l:spell },
      \     'tags':  { t -> !empty(tagfiles()) },
      \     'thes':  { t -> strlen(&l:thesaurus) > 0 },
      \     'user':  { t -> strlen(&l:completefunc) > 0 }
      \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
      \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')

" Note: In 'c-n' and 'c-p' below we use the fact that pressing <c-x> while in
" ctrl-x submode doesn't do anything and any key that is not valid in ctrl-x
" submode silently ends that mode (:h complete_CTRL-Y) and inserts the key.
" Hence, after <c-x><c-b>, we are surely out of ctrl-x submode. The subsequent
" <bs> is used to delete the inserted <c-b>. We use <c-b> because it is not
" mapped (:h i_CTRL-B-gone). This trick is needed to have <c-p> (an <c-n>)
" trigger keyword completion under all circumstances, in particular when the
" current mode is the ctrl-x submode. (pressing <c-p>, say, immediately after
" <c-x><c-o> would do a different thing).
let g:mucomplete#exit_ctrlx_keys = "\<c-b>\<bs>"

" Internal status
let s:cnp = "\<c-x>".g:mucomplete#exit_ctrlx_keys
let s:compl_mappings = extend({
      \ 'c-n'     :  [s:cnp."\<c-n>\<c-p>\<c-n>", s:cnp."\<c-n>\<c-p>"],
      \ 'c-p'     :  [s:cnp."\<c-p>\<c-n>\<c-p>", s:cnp."\<c-p>\<c-n>"],
      \ 'cmd'     :  ["\<c-x>\<c-v>\<c-p>\<c-n>", "\<c-x>\<c-v>\<c-p>"],
      \ 'defs'    :  ["\<c-x>\<c-d>\<c-p>\<c-n>", "\<c-x>\<c-d>\<c-p>"],
      \ 'dict'    :  ["\<c-x>\<c-k>\<c-p>\<c-n>", "\<c-x>\<c-k>\<c-p>"],
      \ 'file'    :  ["\<c-x>\<c-f>\<c-p>\<c-n>", "\<c-x>\<c-f>\<c-p>"],
      \ 'incl'    :  ["\<c-x>\<c-i>\<c-p>\<c-n>", "\<c-x>\<c-i>\<c-p>"],
      \ 'keyn'    :  ["\<c-x>\<c-n>\<c-p>\<c-n>", "\<c-x>\<c-n>\<c-p>"],
      \ 'keyp'    :  ["\<c-x>\<c-p>\<c-n>\<c-p>", "\<c-x>\<c-p>\<c-n>"],
      \ 'line'    :  ["\<c-x>\<c-l>\<c-n>\<c-p>", "\<c-x>\<c-l>\<c-p>"],
      \ 'omni'    :  ["\<c-x>\<c-o>\<c-p>\<c-n>", "\<c-x>\<c-o>\<c-p>"],
      \ 'spel'    :  ["\<c-x>s\<c-p>\<c-n>"     , "\<c-x>s\<c-p>"     ],
      \ 'tags'    :  ["\<c-x>\<c-]>\<c-n>\<c-p>", "\<c-x>\<c-]>\<c-p>"],
      \ 'thes'    :  ["\<c-x>\<c-t>\<c-n>\<c-p>", "\<c-x>\<c-t>\<c-p>"],
      \ 'user'    :  ["\<c-x>\<c-u>\<c-n>\<c-p>", "\<c-x>\<c-u>\<c-p>"]
      \ }, get(g:, 'mucomplete#user_mappings', {}), 'error')
unlet s:cnp
let s:compl_methods = []
let s:compl_text = ''
let s:auto = 0
let s:i = -1

" Workhorse function for chained completion. Do not call directly.
fun! mucomplete#complete_chain()
  if pumvisible()
    return ''
  endif
  let s:i += 1
  while s:i < len(s:compl_methods) &&
        \ !get(get(g:mucomplete#can_complete, getbufvar("%","&ft"), {}),
        \          s:compl_methods[s:i],
        \          get(g:mucomplete#can_complete['default'], s:compl_methods[s:i], s:yes_you_can)
        \ )(s:compl_text)
    let s:i += 1
  endwhile
  if s:i < len(s:compl_methods)
    return s:compl_mappings[s:compl_methods[s:i]][s:auto] . "\<plug>(MUcompleteNxt)"
  endif
  return ''
endf

fun! s:complete(rev)
  let s:compl_methods = get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default'])
  if a:rev
    let s:compl_methods = reverse(copy(s:compl_methods))
  endif
  return mucomplete#complete_chain()
endf

fun! mucomplete#complete(rev)
  if pumvisible()
    return a:rev ? "\<c-p>" : "\<c-n>"
  endif
  let s:i = -1
  let s:auto = exists('#MUcompleteAuto')
  let s:compl_text = matchstr(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  return strlen(s:compl_text) == 0
        \ ? (a:rev ? "\<plug>(MUcompleteCtd)" : "\<plug>(MUcompleteTab)")
        \ : s:complete(a:rev)
endf

fun! mucomplete#autocomplete()
  if match(strpart(getline('.'), 0, col('.') - 1),
        \  get(g:mucomplete#trigger_auto_pattern, getbufvar("%", "&ft"),
        \      g:mucomplete#trigger_auto_pattern['default'])) > -1
    silent call feedkeys("\<plug>(MUcompleteFwd)", 'i')
  endif
endf

let &cpo = s:save_cpo
unlet s:save_cpo
