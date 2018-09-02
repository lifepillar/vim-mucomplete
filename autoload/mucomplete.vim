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
inoremap <silent>        <plug>(MUcompleteCte) <c-e>
imap     <silent> <expr> <plug>(MUcompleteCyc) <sid>cycle()
inoremap <silent>        <plug>(MUcompleteUp)  <up>
inoremap <silent>        <plug>(MUcompleteDown) <down>

fun! s:errmsg(msg)
  echohl ErrorMsg
  echomsg "[MUcomplete]" a:msg
  echohl NONE
endf

fun! mucomplete#map(mode, lhs, rhs)
  try
    execute a:mode '<silent> <unique>' a:lhs a:rhs
  catch /^Vim\%((\a\+)\)\=:E227/
    call s:errmsg(a:lhs . ' is already mapped (use `:verbose '.a:mode.' '.a:lhs.'` to see by whom). See :help mucomplete-compatibility.')
  endtry
endf

if !get(g:, 'mucomplete#no_mappings', get(g:, 'no_plugin_maps', 0))
  if !hasmapto('<plug>(MUcompleteCycFwd)', 'i')
    inoremap <silent> <plug>(MUcompleteFwdKey) <c-j>
    call mucomplete#map('imap', '<c-j>', '<plug>(MUcompleteCycFwd)')
  endif
  if !hasmapto('<plug>(MUcompleteCycBwd)', 'i')
    inoremap <silent> <plug>(MUcompleteBwdKey) <c-h>
    call mucomplete#map('imap', '<c-h>', '<plug>(MUcompleteCycBwd)')
  endif
endif

if exists('g:mucomplete#smart_enter')
  call s:errmsg("g:mucomplete#smart_enter has been removed. See :help mucomplete-tips.")
endif

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
let s:default_dir = { 'c-p' : -1, 'keyp': -1, 'line': -1 }
let s:pathstart = exists('+shellslash') && !&shellslash
      \ ? (get(g:, 'mucomplete#use_only_windows_paths', 0) ? '[\\~]' : '[/\\~]')
      \ : '[/~]'

" Internal state
let s:compl_methods = ['keyn'] " Current completion chain
let s:N = 0                    " Length of the current completion chain
let s:i = 0                    " Index of the current completion method in the completion chain
let s:countdown = 0            " Keeps track of how many other completion attempts to try
let s:compl_text = ''          " Text to be completed
let s:dir = 1                  " Direction to search for the next completion method (1=fwd, -1=bwd)
let s:complete_empty_text = 0  " When set to 1, completion is tried even at the start of the line or after a space
let s:noselect = 0             " Set to 1 when completeopt contains 'noselect'; 0 otherwise
let s:noinsert = 0             " Set to 1 when completeopt contains 'noinsert'; 0 otherwise
let g:mucomplete_with_key = 1  " Was completion triggered by a key?

if has("patch-7.4.775") || (v:version == 704 && has("patch775"))  " noinsert and noselect added there
  fun! s:set_cot()
    let s:noselect = (stridx(&l:completeopt, 'noselect') != -1)
    let s:noinsert = (stridx(&l:completeopt, 'noinsert') != -1)
  endf

  fun! s:select_entry(dir) " argument is the natural direction of the current method
    return ''
  endf
else " First menu entry is always selected and inserted
  fun! s:set_cot()
    " noop
  endf

  fun! s:select_entry(dir)
    return (a:dir > 0 ? "\<c-p>" : "\<c-n>") " Works as with noselect
  endf
endif

" Completion chains
let g:mucomplete#chains = extend({
      \ 'default' : ['path', 'omni', 'keyn', 'dict', 'uspl'],
      \ 'vim'     : ['path', 'cmd',  'keyn']
      \ }, get(g:, 'mucomplete#chains', {}))

" Conditions to be verified for a given method to be applied.
if has('lambda')
  let s:yes_you_can = { _ -> 1 } " Try always
  let s:is_keyword = { t -> t =~# '\m\k\k$' || (g:mucomplete_with_key && (s:complete_empty_text || t =~# '\m\k$')) }
  let s:is_keyword_or_dot = { t -> t =~# '\m\k\%(\k\|\.\)$' || (g:mucomplete_with_key && (s:complete_empty_text || t =~# '\m\%(\k\|\.\)$')) }
  let g:mucomplete#can_complete = extend({
        \ 'default' : extend({
        \     'c-n' : s:is_keyword,
        \     'c-p' : s:is_keyword,
        \     'cmd' : s:is_keyword,
        \     'defs': s:is_keyword,
        \     'dict': { t -> strlen(&l:dictionary) > 0 && (t =~# '\m\a\a$' || (g:mucomplete_with_key && t =~# '\m\a$')) },
        \     'file': { t -> t =~# '\m'.s:pathstart.'\f*$' },
        \     'incl': s:is_keyword,
        \     'keyn': s:is_keyword,
        \     'keyp': s:is_keyword,
        \     'line': s:is_keyword,
        \     'omni': { t -> strlen(&l:omnifunc) > 0 && s:is_keyword(t) },
        \     'path': { t -> t =~# '\m'.s:pathstart.'\%(\f\|\s\)*$' },
        \     'spel': { t -> &l:spell && !empty(&l:spelllang) && t =~# '\m\a\a\a$' },
        \     'tags': { t -> !empty(tagfiles()) && s:is_keyword(t) },
        \     'thes': { t -> strlen(&l:thesaurus) > 0 && t =~# '\m\a\a\a$' },
        \     'ulti': { t -> get(g:, 'did_plugin_ultisnips', 0) && s:is_keyword(t) },
        \     'user': { t -> strlen(&l:completefunc) > 0 && s:is_keyword(t) },
        \     'uspl': { t -> &l:spell && !empty(&l:spelllang) && t =~# '\m\a\a\a$' }
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
  " Special cases
  if has('python') || has('python3')
    call extend(extend(g:mucomplete#can_complete, { 'python': {} }, 'keep')['python'], { 'omni': s:is_keyword_or_dot }, 'keep')
  endif
else
  let s:yes_you_can = function('mucomplete#compat#yes_you_can')
  let g:mucomplete#can_complete = mucomplete#compat#can_complete()
endif

fun! s:can_complete(i) " Is the i-th completion method applicable?
  return get(get(g:mucomplete#can_complete, getbufvar("%","&ft"), {}),
        \          s:compl_methods[a:i],
        \          get(g:mucomplete#can_complete['default'], s:compl_methods[a:i], s:yes_you_can)
        \ )(s:compl_text)
endf

fun! s:select_dir()
  return extend({ 'c-p' : -1, 'keyp': -1, 'line': -1 }, get(g:, 'mucomplete#popup_direction', {}))
endf

fun! s:fix_auto_select() " Select the correct entry taking into account g:mucomplete#popup_direction
  let l:m = s:compl_methods[s:i]
  return get(s:default_dir, l:m, 1) == get(s:select_dir(), l:m, 1) || s:noselect
        \ ? s:select_entry(get(s:default_dir, l:m, 1))
        \ : (get(s:default_dir, l:m, 1) > get(s:select_dir(), l:m, 1)
        \    ? "\<plug>(MUcompleteUp)\<plug>(MUcompleteUp)"
        \    : "\<plug>(MUcompleteDown)\<plug>(MUcompleteDown)")
endf

fun! s:insert_entry() " Select and insert a pop-up entry, overriding noselect and noinsert
  let l:m = s:compl_methods[s:i]
  return get(s:default_dir, l:m, 1) == get(s:select_dir(), l:m, 1)
        \ ? (s:noselect
        \    ? (get(s:default_dir, l:m, 1) > 0 ? "\<c-n>" : "\<c-p>")
        \    : (s:noinsert ? "\<plug>(MUcompleteUp)\<c-n>" : '')
        \   )
        \ : (get(s:default_dir, l:m, 1) > get(s:select_dir(), l:m, 1)
        \    ? (s:noselect ?  "\<c-p>" : "\<c-p>\<c-p>")
        \    : (s:noselect ? "\<c-n>" : "\<c-n>\<c-n>")
        \   )
endf

fun! s:act_on_pumvisible()
  call s:set_cot()
  let g:mucomplete#completion_type = s:compl_methods[s:i]
  silent doautocmd User MUcompletePmenu
  return !g:mucomplete_with_key || get(g:, 'mucomplete#always_use_completeopt', 0) || (index(['spel','uspl'], get(s:compl_methods, s:i, '')) > - 1)
        \ ? s:fix_auto_select()
        \ : s:insert_entry()
endf

fun! s:try_completion() " Assumes s:i in [0, s:N - 1]
  let g:mucomplete#completion_type = s:compl_methods[s:i]
  return s:compl_mappings[s:compl_methods[s:i]] . "\<c-r>\<c-r>=''\<cr>\<plug>(MUcompleteVerify)"
endf

" Precondition: pumvisible() is false.
fun! s:next_method()
  while s:countdown > 0
    let s:countdown -= 1
    let s:i = (s:i + s:dir + s:N) % s:N
    if s:can_complete(s:i)
      return s:try_completion()
    endif
  endwhile
  return ''
endf

fun! s:verify_completion()
  return pumvisible()
            \ ? s:act_on_pumvisible()
            \ : (s:compl_methods[s:i] ==# 'cmd' ? s:ctrlx_out : '')
            \ . s:next_method()
endf

fun! s:extend_completion(dir, keys)
  return pumvisible() && index(['keyn', 'keyp', 'c-n', 'c-p', 'defs', 'incl', 'line'], s:compl_methods[s:i]) > -1
        \ ? (index(['keyn','keyp','c-n','c-p'], s:compl_methods[s:i]) > -1
        \   ? (a:dir > 0 ? "\<c-x>\<c-n>" : "\<c-x>\<c-p>")
        \   : (s:compl_methods[s:i] ==# 'line' ? "\<c-x>\<c-l>" : s:compl_mappings[s:compl_methods[s:i]]
        \     )
        \   )
        \   .
        \   (a:dir > 0
        \    ? (s:noselect
        \      ? "\<plug>(MUcompleteDown)\<c-p>\<c-n>"
        \      : (s:noinsert ? "\<plug>(MUcompleteUp)\<c-n>" : '')
        \      )
        \    : (s:noselect
        \      ? "\<plug>(MUcompleteUp)\<c-n>\<c-p>"
        \      : (s:noinsert ? "\<plug>(MUcompleteDown)\<c-p>" : '')
        \      )
        \   )
        \ : a:keys
endf

fun! mucomplete#extend_fwd(keys)
  return s:extend_completion(1, a:keys)
endf

fun! mucomplete#extend_bwd(keys)
  return s:extend_completion(-1, a:keys)
endf

fun! s:cycle()
  let g:mucomplete_with_key = g:mucomplete_with_key || get(g:, 'mucomplete#cycle_all', 0)
  let s:compl_text = mucomplete#get_compl_text()
  let s:countdown = s:N " Reset counter
  return s:next_method()
endf

fun! mucomplete#cycle(dir)
  let s:dir = a:dir
  return pumvisible()
        \ ? "\<plug>(MUcompleteCte)\<plug>(MUcompleteCyc)"
        \ : (a:dir > 0 ? "\<plug>(MUcompleteFwdKey)" : "\<plug>(MUcompleteBwdKey)")
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle_or_select(dir)
  return get(g:, 'mucomplete#cycle_with_trigger', 0)
        \ ? mucomplete#cycle(a:dir)
        \ : (get(s:select_dir(), s:compl_methods[s:i], 1) * a:dir > 0 ? "\<c-n>" : "\<c-p>")
endf

" Precondition: pumvisible() is false.
fun! mucomplete#init(dir, tab_completion) " Initialize/reset internal state
  let g:mucomplete_with_key = a:tab_completion
  let s:dir = a:dir
  let s:compl_methods = get(b:, 'mucomplete_chain',
        \ get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default']))
  let s:N = len(s:compl_methods)
  let s:countdown = s:N
  let s:i = s:dir > 0 ? -1 : s:N
endf

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
    let s:compl_text = mucomplete#get_compl_text()
    let s:complete_empty_text = get(b:, 'mucomplete_empty_text', get(g:, 'mucomplete#empty_text', 0))
    if (empty(s:compl_text) || s:compl_text =~# '\m\s$') && !s:complete_empty_text
      return (a:dir > 0 ? "\<plug>(MUcompleteTab)" : "\<plug>(MUcompleteCtd)")
    endif
    call mucomplete#init(a:dir, 1)
    return s:next_method()
  endif
endf

fun! mucomplete#auto_complete()
  let s:compl_text = mucomplete#get_compl_text()
  call mucomplete#init(1, 0)
  while s:countdown > 0
    let s:countdown -= 1
    let s:i += 1
    if s:can_complete(s:i)
      return feedkeys("\<plug>(MUcompleteTry)", 'i')
    endif
  endwhile
endf

let &cpo = s:save_cpo
unlet s:save_cpo

