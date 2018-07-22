" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

imap     <silent> <expr> <plug>(MUcompleteTry) <sid>try_completion()
imap     <silent> <expr> <plug>(MUcompleteVerify) <sid>verify_completion()
inoremap <silent>        <plug>(MUcompleteOut) <c-g><c-g>
inoremap <silent>        <plug>(MUcompleteTab) <tab>
inoremap <silent>        <plug>(MUcompleteCtd) <c-d>

let s:ctrlx_out = "\<plug>(MUcompleteOut)"
let s:compl_mappings = extend({
      \ 'c-n' : s:ctrlx_out."\<c-n>",
      \ 'c-p' : s:ctrlx_out."\<c-p>",
      \ 'cmd' : "\<c-x>\<c-v>",
      \ 'defs': "\<c-x>\<c-d>",
      \ 'dict': "\<c-x>\<c-k>",
      \ 'file': "\<c-x>\<c-f>",
      \ 'incl': "\<c-x>\<c-i>",
      \ 'keyn': "\<c-x>\<c-n>",
      \ 'keyp': "\<c-x>\<c-p>",
      \ 'line': s:ctrlx_out."\<c-x>\<c-l>",
      \ 'omni': "\<c-x>\<c-o>",
      \ 'spel': "\<c-x>s"     ,
      \ 'tags': "\<c-x>\<c-]>",
      \ 'thes': "\<c-x>\<c-t>",
      \ 'user': "\<c-x>\<c-u>",
      \ 'ulti': "\<c-r>=mucomplete#ultisnips#complete()\<cr>",
      \ 'path': "\<c-r>=mucomplete#path#complete()\<cr>",
      \ 'uspl': s:ctrlx_out."\<c-r>=mucomplete#spel#complete()\<cr>"
      \ }, get(g:, 'mucomplete#user_mappings', {}), 'error')
let s:default_dir = { 'c-p' : -1, 'keyp': -1 }
let s:select_dir = extend({ 'c-p' : -1, 'keyp': -1 }, get(g:, 'mucomplete#popup_direction', {}))
let s:pathsep = exists('+shellslash') && !&shellslash ? '\\' : '/'

" Internal state
let s:compl_methods = [] " Current completion chain
let s:N = 0              " Length of the current completion chain
let s:i = 0              " Index of the current completion method in the completion chain
let s:countdown = 0      " Keeps track of how many other completion attempts to try
let s:compl_text = ''    " Text to be completed
let s:auto = 0           " Is autocompletion enabled?
let s:dir = 1            " Direction to search for the next completion method (1=fwd, -1=bwd)
let s:cancel_auto = 0    " Used to detect whether the user leaves the pop-up menu with ctrl-y, ctrl-e, or enter.
let s:insertcharpre = 0  " Was a non-whitespace character inserted?

fun! mucomplete#popup_exit(ctrl)
  let s:cancel_auto = pumvisible()
  return s:cancel_auto && get(g:, "mucomplete#smart_enter", 0) && a:ctrl == "\<cr>"
        \ ? "\<c-y>" . a:ctrl
        \ : a:ctrl
endf

fun! mucomplete#insert_char_pre()
  let s:insertcharpre = (v:char =~# '\m\S')
endf

fun! mucomplete#act_on_textchanged() " Assumes pumvisible() is false. Return value is not used.
  return s:cancel_auto
        \ ? extend(s:, { 'cancel_auto': 0, 'insertcharpre': 0 })
        \ : (s:insertcharpre
        \   ? (get(mucomplete#init(1, 0), 0, 1) && s:next_method() ? feedkeys("\<plug>(MUcompleteTry)", 'i') : 0)
        \   : 0
        \   )
endf

"   if s:insertcharpre
"     let s:insertcharpre = 0
"     let s:compl_text = mucomplete#get_compl_text()
"     call mucomplete#init(1, 0)
"     while s:countdown > 0
"       let s:countdown -= 1
"       let s:i += 1
"       if s:can_complete(s:i)
"         return feedkeys("\<plug>(MUcompleteTry)", 'i')
"       endif
"     endwhile
"   endif
" endf

fun! mucomplete#enable_auto()
  augroup MUcompleteAuto
    autocmd!
    autocmd InsertCharPre * noautocmd call mucomplete#insert_char_pre()
    autocmd TextChangedI  * noautocmd call mucomplete#act_on_textchanged()
  augroup END
endf

fun! mucomplete#disable_auto()
  if exists('#MUcompleteAuto')
    autocmd! MUcompleteAuto
    augroup! MUcompleteAuto
  endif
endf

if exists('g:mucomplete#trigger_auto_pattern')
  echomsg "[MUcomplete] g:mucomplete#trigger_auto_pattern has been removed. Use g:mucomplete#can_complete instead."
endif

" Completion chains
let g:mucomplete#chains = extend({
      \ 'default' : [has('patch-7.3.465') ? 'path' : 'file', 'omni', 'keyn', 'dict', 'uspl'],
      \ 'vim'     : [has('patch-7.3.465') ? 'path' : 'file', 'cmd',  'keyn']
      \ }, get(g:, 'mucomplete#chains', {}))

" Conditions to be verified for a given method to be applied.
if has('lambda')
  let s:yes_you_can = { _ -> 1 } " Try always
  let g:mucomplete#can_complete = extend({
        \ 'default' : extend({
        \     'c-n' : { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'c-p' : { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'cmd' : { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'defs': { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'dict': { t -> strlen(&l:dictionary) > 0 && (g:mucomplete_with_key || t =~# '\m\a\a$') },
        \     'file': { t -> t =~# '\m\%('.s:pathsep.'\|\~\)\f*$' },
        \     'incl': { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'keyn': { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'keyp': { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'line': { t -> g:mucomplete_with_key || t =~# '\m\k\k$' },
        \     'omni': { t -> strlen(&l:omnifunc) > 0 && (g:mucomplete_with_key || t =~# '\m\k\k$') },
        \     'spel': { t -> &l:spell && !empty(&l:spelllang) && t =~# '\m\a\a\a$' },
        \     'tags': { t -> !empty(tagfiles()) && (g:mucomplete_with_key || t =~# '\m\k\k$') },
        \     'thes': { t -> strlen(&l:thesaurus) > 0 && t =~# '\m\a\a\a$' },
        \     'user': { t -> strlen(&l:completefunc) > 0 && (g:mucomplete_with_key || t =~# '\m\k\k$') },
        \     'path': { t -> t =~# '\m\%('.s:pathsep.'\|\~\)\f*$' },
        \     'uspl': { t -> &l:spell && !empty(&l:spelllang) && t =~# '\m\a\a\a$' },
        \     'ulti': { t -> get(g:, 'did_plugin_ultisnips', 0) && (g:mucomplete_with_key || t =~# '\m\k\k$') }
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
else
  let s:yes_you_can = function('mucomplete#compat#yes_you_can')
  let g:mucomplete#can_complete = mucomplete#compat#can_complete()
endif

fun! s:insert_entry() " Select and insert a pop-up entry, overriding noselect and noinsert
  let l:m = s:compl_methods[s:i]
  return get(s:default_dir, l:m, 1) == get(s:select_dir, l:m, 1)
        \ ? (stridx(&l:completeopt, 'noselect') == -1
        \    ? (stridx(&l:completeopt, 'noinsert') == -1 ? '' : "\<up>\<c-n>")
        \    : (get(s:default_dir, l:m, 1) > 0 ? "\<c-n>" : "\<c-p>")
        \   )
        \ : (get(s:default_dir, l:m, 1) > get(s:select_dir, l:m, 1)
        \    ? (stridx(&l:completeopt, 'noselect') == -1 ? "\<c-p>\<c-p>" : "\<c-p>")
        \    : (stridx(&l:completeopt, 'noselect') == -1 ? "\<c-n>\<c-n>" : "\<c-n>")
        \   )
endf

fun! s:fix_auto_select() " Select the correct entry taking into account g:mucomplete#popup_direction
  let l:m = s:compl_methods[s:i]
  return get(s:default_dir, l:m, 1) == get(s:select_dir, l:m, 1) || stridx(&l:completeopt, 'noselect') != -1
        \ ? ''
        \ : (get(s:default_dir, l:m, 1) > get(s:select_dir, l:m, 1) ? "\<up>\<up>" : "\<down>\<down>")
endf

fun! s:act_on_pumvisible()
  return s:auto || (index(['spel','uspl'], get(s:compl_methods, s:i, '')) > - 1)
        \ ? s:fix_auto_select()
        \ : s:insert_entry()
endf

fun! s:can_complete(i) " Is the i-th completion method applicable?
  return get(get(g:mucomplete#can_complete, getbufvar("%","&ft"), {}),
        \          s:compl_methods[a:i],
        \          get(g:mucomplete#can_complete['default'], s:compl_methods[a:i], s:yes_you_can)
        \ )(s:compl_text)
endf

fun! s:try_completion() " Assumes s:i in [0, s:N - 1]
  return s:compl_mappings[s:compl_methods[s:i]] . "\<c-r>\<c-r>=''\<cr>\<plug>(MUcompleteVerify)"
endf

fun! s:next_completion()
  return s:next_method() ? s:try_completion() : ''
endf

" Precondition: pumvisible() is false.
fun! s:next_method()
  return s:countdown > 0
        \ ? (get(extend(s:, { 'countdown': s:countdown - 1, 'i': (s:i + s:dir + s:N) % s:N }), 1, 1) && s:can_complete(s:i)
        \   ? 1
        \   : s:next_method()
        \   )
        \ : 0
endf

fun! s:verify_completion()
  return pumvisible()
            \ ? s:act_on_pumvisible()
            \ : (s:compl_methods[s:i] ==# 'cmd' ? s:ctrlx_out : '')
            \ . s:next_completion()
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle(dir)
  if pumvisible()
    let s:dir = a:dir
    let s:countdown = s:N " Reset counter
    return "\<plug>(MUcompleteCte)" . s:next_completion()
  else
    return a:dir > 0 ? "\<plug>(MUcompleteFwdKey)" : "\<plug>(MUcompleteBwdKey)"
  endif
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle_or_select(dir)
  return get(g:, 'mucomplete#cycle_with_trigger', 0)
        \ ? mucomplete#cycle(a:dir)
        \ : (get(s:select_dir, s:compl_methods[s:i], 1) * a:dir > 0 ? "\<c-n>" : "\<c-p>")
endf

" Precondition: pumvisible() is false.
fun! mucomplete#init(dir, tab_completion) " Initialize/reset internal state.
  let g:mucomplete_with_key = a:tab_completion
  return extend(extend(s:, {
        \  'compl_methods': get(b:, 'mucomplete_chain', get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default'])),
        \  'compl_text': mucomplete#get_compl_text(),
        \  'dir': a:dir,
        \  'insertcharpre': 0
        \ }), { 'N': len(s:compl_methods), 'countdown': len(s:compl_methods), 'i': s:dir > 0 ? -1 : len(s:compl_methods)}
        \ )
endf

" fun! mucomplete#init(dir, tab_completion) " Initialize/reset internal state
"   let g:mucomplete_with_key = a:tab_completion
"   let s:dir = a:dir
"   let s:compl_methods = get(b:, 'mucomplete_chain',
"         \ get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default']))
"   let s:N = len(s:compl_methods)
"   let s:countdown = s:N
"   let s:i = s:dir > 0 ? -1 : s:N
" endf
"
fun! mucomplete#get_compl_text()
  return col('.') <= get(g:, 'mucomplete#look_behind', 30)
        \ ? (col('.') == 1
        \   ? ''
        \   : getline('.')[0:col('.') - 2])
        \ : getline('.')[col('.') - 1 - get(g:, 'mucomplete#look_behind', 30):col('.') - 2]
endf

fun! mucomplete#tab_complete(dir)
  if pumvisible()
    return mucomplete#cycle_or_select(a:dir)
  else
    call mucomplete#init(a:dir, 1)
    let s:complete_empty_text = get(b:, 'mucomplete_empty_text', get(g:, 'mucomplete#empty_text', 0))
    if (empty(s:compl_text) || s:compl_text =~# '\m\s$') && !s:complete_empty_text
      return (a:dir > 0 ? "\<plug>(MUcompleteTab)" : "\<plug>(MUcompleteCtd)")
    endif
    return s:next_completion()
  endif
endf

let &cpo = s:save_cpo
unlet s:save_cpo
