" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

" Note: In 'c-n' and 'c-p' below we use the fact that pressing <c-x> while in
" ctrl-x submode doesn't do anything and any key that is not valid in ctrl-x
" submode silently ends that mode (:h complete_CTRL-Y) and inserts the key.
" Hence, after <c-x><c-b>, we are surely out of ctrl-x submode. The subsequent
" <bs> is used to delete the inserted <c-b>. We use <c-b> because it is not
" mapped (:h i_CTRL-B-gone). This trick is needed to have <c-p> (and <c-n>)
" trigger keyword completion under all circumstances, in particular when the
" current mode is the ctrl-x submode. (pressing <c-p>, say, immediately after
" <c-x><c-o> would do a different thing).

let s:cnp = "\<c-x>" . get(g:, 'mucomplete#exit_ctrlx_keys', "\<c-b>\<bs>")
let s:compl_mappings = extend({
      \ 'c-n' : s:cnp."\<c-n>", 'c-p' : s:cnp."\<c-p>",
      \ 'cmd' : "\<c-x>\<c-v>", 'defs': "\<c-x>\<c-d>",
      \ 'dict': "\<c-x>\<c-k>", 'file': "\<c-x>\<c-f>",
      \ 'incl': "\<c-x>\<c-i>", 'keyn': "\<c-x>\<c-n>",
      \ 'keyp': "\<c-x>\<c-p>", 'line': s:cnp."\<c-x>\<c-l>",
      \ 'omni': "\<c-x>\<c-o>", 'spel': "\<c-x>s"     ,
      \ 'tags': "\<c-x>\<c-]>", 'thes': "\<c-x>\<c-t>",
      \ 'user': "\<c-x>\<c-u>", 'ulti': "\<c-r>=mucomplete#ultisnips#complete()\<cr>",
      \ 'path': "\<c-r>=mucomplete#path#complete()\<cr>",
      \ 'uspl': "\<c-o>:call mucomplete#spel#gather()\<cr>\<c-r>=mucomplete#spel#complete()\<cr>"
      \ }, get(g:, 'mucomplete#user_mappings', {}), 'error')
unlet s:cnp
let s:select_entry = { 'c-p' : "\<c-p>\<down>", 'keyp': "\<c-p>\<down>" }
let s:pathsep = exists('+shellslash') && !&shellslash ? '\\' : '/'
" Internal state
let s:compl_methods = []
let s:compl_text = ''
let s:auto = 0
let s:dir = 1
let s:cycle = 0
let s:i = 0
let s:pumvisible = 0

if exists('##TextChangedI') && exists('##CompleteDone')
  fun! s:act_on_textchanged()
    if s:completedone
      let s:completedone = 0
      let g:mucomplete_with_key = 0
      if get(s:compl_methods, s:i, '') ==# 'path' && getline('.')[col('.')-2] =~# '\m\f'
        silent call mucomplete#path#complete()
      elseif get(s:compl_methods, s:i, '') ==# 'file' && getline('.')[col('.')-2] =~# '\m\f'
        silent call feedkeys("\<c-x>\<c-f>", 'i')
      endif
    elseif !&g:paste && match(strpart(getline('.'), 0, col('.') - 1),
          \  get(g:mucomplete#trigger_auto_pattern, getbufvar("%", "&ft"),
          \      g:mucomplete#trigger_auto_pattern['default'])) > -1
      silent call feedkeys("\<plug>(MUcompleteAuto)", 'i')
    endif
  endf

  fun! mucomplete#enable_auto()
    let s:completedone = 0
    let g:mucomplete_with_key = 0
    augroup MUcompleteAuto
      autocmd!
      autocmd TextChangedI * noautocmd call s:act_on_textchanged()
      autocmd CompleteDone * noautocmd let s:completedone = 1
    augroup END
    let s:auto = 1
  endf

  fun! mucomplete#disable_auto()
    if exists('#MUcompleteAuto')
      autocmd! MUcompleteAuto
      augroup! MUcompleteAuto
    endif
    let s:auto = 0
  endf

  fun! mucomplete#toggle_auto()
    if exists('#MUcompleteAuto')
      call mucomplete#disable_auto()
      echomsg '[MUcomplete] Auto off'
    else
      call mucomplete#enable_auto()
      echomsg '[MUcomplete] Auto on'
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

" Conditions to be verified for a given method to be applied.
if has('lambda')
  let s:yes_you_can = { _ -> 1 } " Try always
  let g:mucomplete#can_complete = extend({
        \ 'default' : extend({
        \     'dict':  { t -> strlen(&l:dictionary) > 0 },
        \     'file':  { t -> t =~# '\m\%('.s:pathsep.'\|\~\)\f*$' },
        \     'omni':  { t -> strlen(&l:omnifunc) > 0 },
        \     'spel':  { t -> &l:spell && !empty(&l:spelllang) },
        \     'tags':  { t -> !empty(tagfiles()) },
        \     'thes':  { t -> strlen(&l:thesaurus) > 0 },
        \     'user':  { t -> strlen(&l:completefunc) > 0 },
        \     'path':  { t -> t =~# '\m\%('.s:pathsep.'\|\~\)\f*$' },
        \     'uspl':  { t -> &l:spell && !empty(&l:spelllang) },
        \     'ulti':  { t -> get(g:, 'did_plugin_ultisnips', 0) }
        \   }, get(get(g:, 'mucomplete#can_complete', {}), 'default', {}))
        \ }, get(g:, 'mucomplete#can_complete', {}), 'keep')
else
  let s:yes_you_can = function('mucomplete#compat#yes_you_can')
  let g:mucomplete#can_complete = mucomplete#compat#can_complete()
endif

fun! s:act_on_pumvisible()
  let s:pumvisible = 0
  return s:auto || index(['spel','uspl'], get(s:compl_methods, s:i, '')) > - 1
        \ ? ''
        \ : (stridx(&l:completeopt, 'noselect') == -1
        \     ? (stridx(&l:completeopt, 'noinsert') == - 1 ? '' : "\<up>\<c-n>")
        \     : get(s:select_entry, s:compl_methods[s:i], "\<c-n>\<up>")
        \   )
endf

fun! s:can_complete()
  return get(get(g:mucomplete#can_complete, getbufvar("%","&ft"), {}),
        \          s:compl_methods[s:i],
        \          get(g:mucomplete#can_complete['default'], s:compl_methods[s:i], s:yes_you_can)
        \ )(s:compl_text)
endf

fun! mucomplete#yup()
  let s:pumvisible = 1
  return ''
endf

" Precondition: pumvisible() is false.
fun! s:next_method()
  let s:i = (s:cycle ? (s:i + s:dir + s:N) % s:N : s:i + s:dir)
  while (s:i+1) % (s:N+1) != 0  && !s:can_complete()
    let s:i = (s:cycle ? (s:i + s:dir + s:N) % s:N : s:i + s:dir)
  endwhile
  if (s:i+1) % (s:N+1) != 0
    return s:compl_mappings[s:compl_methods[s:i]] . "\<c-r>\<c-r>=pumvisible()?mucomplete#yup():''\<cr>\<plug>(MUcompleteNxt)"
  endif
  return ''
endf

fun! mucomplete#verify_completion()
  return s:pumvisible ? s:act_on_pumvisible() : s:next_method()
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle(dir)
  let [s:dir, s:cycle] = [a:dir, 1]
  return "\<c-e>" . s:next_method()
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle_or_select(dir)
  return get(g:, 'mucomplete#cycle_with_trigger', 0)
        \ ? mucomplete#cycle(a:dir)
        \ : (a:dir > 0 ? "\<c-n>" : "\<c-p>")
endf

" Precondition: pumvisible() is false.
fun! mucomplete#complete(dir)
  let s:compl_text = matchstr(strpart(getline('.'), 0, col('.') - 1), '\S\+$')
  if strlen(s:compl_text) == 0
    return (a:dir > 0 ? "\<plug>(MUcompleteTab)" : "\<plug>(MUcompleteCtd)")
  endif
  let [s:dir, s:cycle] = [a:dir, 0]
  let s:compl_methods = get(b:, 'mucomplete_chain',
        \ get(g:mucomplete#chains, getbufvar("%", "&ft"), g:mucomplete#chains['default']))
  let s:N = len(s:compl_methods)
  let s:i = s:dir > 0 ? -1 : s:N
  return s:next_method()
endf

fun! mucomplete#tab_complete(dir)
  if pumvisible()
    return mucomplete#cycle_or_select(a:dir)
  else
    let g:mucomplete_with_key = 1
    return mucomplete#complete(a:dir)
  endif
endf

let &cpo = s:save_cpo
unlet s:save_cpo
