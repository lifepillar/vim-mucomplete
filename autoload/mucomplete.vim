" Chained completion that works as I want!
" Maintainer: Lifepillar <lifepillar@lifepillar.me>
" License: This file is placed in the public domain

let s:save_cpo = &cpo
set cpo&vim

if !empty(mapcheck("\<c-g>\<c-g>", 'i'))
  echohl WarningMsg
  echomsg '[MUcomplete] Warning: <c-g><c-g> is mapped. See :h mucomplete#ctrlx_mode_out'
  echohl none
endif

let s:ctrlx_out = get(g:, 'mucomplete#ctrlx_mode_out', "\<c-g>\<c-g>")
let s:compl_mappings = extend({
      \ 'c-n' : s:ctrlx_out."\<c-n>", 'c-p' : s:ctrlx_out."\<c-p>",
      \ 'cmd' : "\<c-x>\<c-v>", 'defs': "\<c-x>\<c-d>",
      \ 'dict': "\<c-x>\<c-k>", 'file': "\<c-x>\<c-f>",
      \ 'incl': "\<c-x>\<c-i>", 'keyn': "\<c-x>\<c-n>",
      \ 'keyp': "\<c-x>\<c-p>", 'line': s:ctrlx_out."\<c-x>\<c-l>",
      \ 'omni': "\<c-x>\<c-o>", 'spel': "\<c-x>s"     ,
      \ 'tags': "\<c-x>\<c-]>", 'thes': "\<c-x>\<c-t>",
      \ 'user': "\<c-x>\<c-u>", 'ulti': "\<c-r>=mucomplete#ultisnips#complete()\<cr>",
      \ 'path': "\<c-r>=mucomplete#path#complete()\<cr>",
      \ 'uspl': "\<c-r>=mucomplete#spel#complete()\<cr>"
      \ }, get(g:, 'mucomplete#user_mappings', {}), 'error')
let s:select_entry = { 'c-p' : "\<c-p>", 'keyp': "\<c-p>" }
let s:pathsep = exists('+shellslash') && !&shellslash ? '\\' : '/'
" Internal state
let s:compl_methods = [] " Current completion chain
let s:N = 0              " Length of the current completion chain
let s:i = 0              " Index of the current completion method in the completion chain
let s:compl_text = ''    " Text to be completed
let s:auto = 0           " Is autocompletion enabled?
let s:dir = 1            " Direction to search for the next completion method (1=fwd, -1=bwd)
let s:cycle = 0          " Should µcomplete treat the completion chain as cyclic?
let s:i_history = []     " To detect loops when using <c-h>/<c-l>
let s:pumvisible = 0     " Has the pop-up menu become visible?

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
      \ 'default' : ['file', 'omni', 'keyn', 'dict'],
      \ 'vim' : ['file', 'cmd', 'keyn']
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
  return s:auto || (index(['spel','uspl'], get(s:compl_methods, s:i, '')) > - 1)
        \ ? ''
        \ : (stridx(&l:completeopt, 'noselect') == -1
        \     ? (stridx(&l:completeopt, 'noinsert') == - 1 ? '' : "\<up>\<c-n>")
        \     : get(s:select_entry, s:compl_methods[s:i], "\<c-n>")
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

fun! s:next_completion()
  return s:compl_mappings[s:compl_methods[s:i]] . "\<c-r>\<c-r>=pumvisible()?mucomplete#yup():''\<cr>\<plug>(MUcompleteNxt)"
endf

" Precondition: pumvisible() is false.
fun! s:next_method()
  let s:i += s:dir
  while (s:i+1) % (s:N+1) != 0 && !s:can_complete()
    let s:i += s:dir
  endwhile
  return (s:i+1) % (s:N+1) != 0 ? s:next_completion() : ''
endf

" Precondition: pumvisible() is false.
fun! s:next_method_cyclic()
  while 1
    let s:i = (s:i + s:dir + s:N) % s:N
    if index(s:i_history, s:i) > -1
      return ''
    endif
    call add(s:i_history, s:i)
    if s:can_complete()
      break
    endif
  endwhile
  return s:next_completion()
endf

fun! mucomplete#verify_completion()
  return s:pumvisible
            \ ? s:act_on_pumvisible()
            \ : (s:compl_methods[s:i] ==# 'cmd' ? s:ctrlx_out : '')
            \ . (s:cycle ? s:next_method_cyclic() : s:next_method())
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle(dir)
  let [s:dir, s:cycle, s:i_history] = [a:dir, 1, []]
  return "\<c-e>" . s:next_method_cyclic()
endf

" Precondition: pumvisible() is true.
fun! mucomplete#cycle_or_select(dir)
  return get(g:, 'mucomplete#cycle_with_trigger', 0)
        \ ? mucomplete#cycle(a:dir)
        \ : (a:dir > 0 ? "\<c-n>" : "\<c-p>")
endf

" Precondition: pumvisible() is false.
fun! mucomplete#complete(dir)
  let s:compl_text = matchstr(getline('.'), '\S\+\%'.col('.').'c')
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
