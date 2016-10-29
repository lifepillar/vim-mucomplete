" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

if exists('##TextChangedI') && exists('##CompleteDone')
  fun! mucomplete#enable_auto()
    let s:completedone = 0
    augroup MUcompleteAuto
      autocmd!
      autocmd TextChangedI * noautocmd if s:completedone | let s:completedone = 0 | else | silent call mucomplete#autocomplete() | endif
      autocmd CompleteDone * noautocmd let s:completedone = 1
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
endif

" Patterns to decide when automatic completion should be triggered.
let g:mucomplete#trigger_auto_pattern = extend({
      \ 'default' : '\k\k$'
      \ }, get(g:, 'mucomplete#trigger_auto_pattern', {}))

" Completion chains
let g:mucomplete#chains = extend({
      \ 'default' : ['file', 'omni', 'keyn', 'dict']
      \ }, get(g:, 'mucomplete#chains', {}))

let g:mucomplete#pathsep = (has('win32') || has('win64') || has('win16') || has('win95')) ? '\' : '/'

" Conditions to be verified for a given method to be applied.
if has('lambda')
  let s:yes_you_can = { _ -> 1 } " Try always
  let g:mucomplete#can_complete = extend({
        \ 'default' : extend({
        \     'dict':  { t -> strlen(&l:dictionary) > 0 },
        \     'file':  { t -> t =~# g:mucomplete#pathsep . '\f*$' },
        \     'omni':  { t -> strlen(&l:omnifunc) > 0 },
        \     'spel':  { t -> &l:spell && !empty(&l:spelllang) },
        \     'tags':  { t -> !empty(tagfiles()) },
        \     'thes':  { t -> strlen(&l:thesaurus) > 0 },
        \     'user':  { t -> strlen(&l:completefunc) > 0 },
        \     'ulti':  { t -> get(g:, 'did_plugin_ultisnips', 0) }
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
else
  let s:yes_you_can = function('mucomplete#compat#yes_you_can')
  let g:mucomplete#can_complete = mucomplete#compat#can_complete()
endif

" Note: In 'c-n' and 'c-p' below we use the fact that pressing <c-x> while in
" ctrl-x submode doesn't do anything and any key that is not valid in ctrl-x
" submode silently ends that mode (:h complete_CTRL-Y) and inserts the key.
" Hence, after <c-x><c-b>, we are surely out of ctrl-x submode. The subsequent
" <bs> is used to delete the inserted <c-b>. We use <c-b> because it is not
" mapped (:h i_CTRL-B-gone). This trick is needed to have <c-p> (and <c-n>)
" trigger keyword completion under all circumstances, in particular when the
" current mode is the ctrl-x submode. (pressing <c-p>, say, immediately after
" <c-x><c-o> would do a different thing).

" Internal status
let s:cnp = "\<c-x>" . get(g:, 'mucomplete#exit_ctrlx_keys', "\<c-b>\<bs>")
let s:compl_mappings = extend({
      \ 'c-n' : s:cnp."\<c-n>", 'c-p' : s:cnp."\<c-p>",
      \ 'cmd' : "\<c-x>\<c-v>", 'defs': "\<c-x>\<c-d>",
      \ 'dict': "\<c-x>\<c-k>", 'file': "\<c-x>\<c-f>",
      \ 'incl': "\<c-x>\<c-i>", 'keyn': "\<c-x>\<c-n>",
      \ 'keyp': "\<c-x>\<c-p>", 'line': "\<c-x>\<c-l>",
      \ 'omni': "\<c-x>\<c-o>", 'spel': "\<c-x>s"     ,
      \ 'tags': "\<c-x>\<c-]>", 'thes': "\<c-x>\<c-t>",
      \ 'user': "\<c-x>\<c-u>", 'ulti': "\<c-r>=mucomplete#ultisnips#complete()\<cr>"
      \ }, get(g:, 'mucomplete#user_mappings', {}), 'error')
unlet s:cnp
let s:compl_methods = []
let s:compl_text = ''
let s:auto = 0
let s:i = -1
let s:pumvisible = 0

fun! mucomplete#yup()
  let s:pumvisible = 1
  return ''
endf

let s:deselect_entry = extend({ 'c-p' : "\<c-n>", 'keyp': "\<c-n>" },
      \ get(g:, 'mucomplete#user_mappings_deselect', {}), 'error')

fun! s:act_on_pumvisible()
  return s:auto
        \ ? (get(s:deselect_entry, s:compl_methods[s:i], "\<c-p>")
        \ . (get(g:, 'mucomplete#auto_select', 0) ? "\<down>" : ''))
        \ : ''
endf

" Workhorse function for chained completion. Do not call directly.
fun! mucomplete#complete_chain()
  if s:pumvisible
    let s:pumvisible = 0
    return s:act_on_pumvisible()
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
    return s:compl_mappings[s:compl_methods[s:i]] . "\<c-r>=pumvisible()?mucomplete#yup():''\<cr>\<plug>(MUcompleteNxt)"
  endif
  return ''
endf

fun! s:complete(rev)
  let s:compl_methods = get(b:, 'mucomplete_chain',
        \ get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default']))
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
