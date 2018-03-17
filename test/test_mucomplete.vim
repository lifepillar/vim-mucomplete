" To run the tests:
"
" 1. vim -u ../troubleshooting_vimrc.vim test_mucomplete.vim
" 2. :source %
"
" TODO: use option_save() and option_restore() when implemented

let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:mudir = fnamemodify(s:testdir, ':h')

execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

" Runs a Vim instance in an environment in which only MUcomplete is loaded.
" Returns the exit status of the Vim instance.
"
" vimrc: a List of commands to add to the vimrc
" cmd:   a List of commands to execute after loading the vimrc.
" ...:   zero or more commands to execute before loading the vimrc.
"
" NOTE: In the list of commands, single quotes, if present, must be escaped.
"
fun! s:vim(vimrc, cmd, ...)
  let l:vimrc_name = 'Xvimrc'
  let l:vimrc = [
        \ 'set nocompatible',
        \ 'set nobackup noswapfile',
        \ 'if has("persistent_undo") | set noundofile | endif',
        \ 'if has("writebackup") | set nowritebackup | endif',
        \ 'if has("packages") | set packpath= | endif',
        \ 'set runtimepath='.fnameescape(s:mudir),
        \ 'set completeopt=menuone'
        \ ]
  let l:vimrc += a:vimrc
  call writefile(l:vimrc, l:vimrc_name)
  let l:opt = ' -u ' . l:vimrc_name . ' -i NONE --not-a-term '
  let l:status = system(v:progpath
        \ . l:opt
        \ . join(map(a:000, { i,v -> "--cmd '" . v . "'"}))
        \ . ' '
        \ . join(map(a:cmd, { i,v -> "-c '" . v . "'"}))
        \ )
  call delete( l:vimrc_name)
  return l:status
endf

fun! Test_MU_buffer_keyword_completion()
  new
  let b:mucomplete_chain = ['keyn']
  MUcompleteAutoOff
  set completeopt=menuone,noinsert,noselect
  call feedkeys("ajump ju", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<esc>", "tx")
  call assert_equal("jump jump", getline(1))
  bwipe!
  set completeopt&
endf

fun! Test_MU_cmd_completion()
  new
  set ft=vim
  let b:mucomplete_chain = ['cmd']
  MUcompleteAutoOff
  set completeopt=menuone,noinsert,noselect
  call feedkeys("aech", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<tab>\<esc>", "tx")
  call assert_equal("echoerr", getline(1))
  bwipe!
  set completeopt&
endf

fun! Test_MU_line_completion()
  new
  let b:mucomplete_chain = ['line']
  MUcompleteAutoOff
  set completeopt=menuone,noinsert,noselect
  call feedkeys("aVim is awesome\<cr>", "tx")
  call feedkeys("aVi", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<esc>", "tx")
  call assert_equal("Vim is awesome", getline(1))
  call assert_equal("Vim is awesome", getline(2))
  bwipe!
  set completeopt&
endf

fun! Test_MU_path_completion_basic()
  new
  execute 'lcd' s:testdir
  let b:mucomplete_chain = ['path']
  MUcompleteAutoOff
  set completeopt=menuone,noselect
  call feedkeys("a./test_m", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<esc>", "tx")
  call assert_equal("./test_mucomplete.vim", getline(1))
  bwipe!
  set completeopt&
endf

fun! Test_MU_path_completion_with_non_default_isfname()
  new
  let b:mucomplete_chain = ['path']
  MUcompleteAutoOff
  try
    set completeopt=menuone,noselect
    set isfname+=@-@,#,{,},*
    execute 'lcd' s:testdir
    call mkdir('tempdir/I * mucomplete/@ @/###/{ok}/}ok{/', "p")
    call feedkeys("a./tempdir/I", "tx")
    call feedkeys("a", "t!")
    call feedkeys("\<tab>\<esc>", "tx")
    call assert_equal("./tempdir/I * mucomplete", getline(1))
    call feedkeys("a/", "t!")
    call feedkeys("\<tab>\<esc>", "tx")
    call assert_equal("./tempdir/I * mucomplete/@ @", getline(1))
    call feedkeys("a/", "t!")
    call feedkeys("\<tab>\<esc>", "tx")
    call assert_equal("./tempdir/I * mucomplete/@ @/###", getline(1))
    call feedkeys("a/{", "t!")
    call feedkeys("\<tab>\<esc>", "tx")
    call assert_equal("./tempdir/I * mucomplete/@ @/###/{ok}", getline(1))
    call feedkeys("a/}", "t!")
    call feedkeys("\<tab>\<esc>", "tx")
    call assert_equal("./tempdir/I * mucomplete/@ @/###/{ok}/}ok{", getline(1))
    bwipe!
  finally
    call delete("tempdir", "rf")
    set completeopt&
    set isfname&
  endtry
endf

fun! Test_MU_uspl_completion()
  new
  setlocal spell
  setlocal spelllang=en
  let b:mucomplete_chain = ['uspl']
  MUcompleteAutoOff
  set completeopt=menuone,noinsert,noselect
  call feedkeys("aspelin", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<tab>\<esc>", "tx")
  call assert_equal("spleen", getline(1))
  call feedkeys("a spelin", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<tab>\<tab>\<esc>", "tx")
  call assert_equal("spleen spelling", getline(1))
  bwipe!
  set completeopt&
endf

fun! Test_MU_issue_87()
  new
  set ft=tex
  let b:mucomplete_chain = ['path', 'omni', 'keyn']
  MUcompleteAutoOff
  set completeopt=menuone,noinsert,noselect
  call feedkeys('a\emph{', "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<esc>", "tx")
  call assert_equal('\emph{', getline(1))
  call assert_equal([], v:errors)
  bwipe!
  set completeopt&
endf

fun! Test_MU_issue_89()
  " Make sure that cyclic plugs are defined before the autoload file is loaded.
  let l:vimrc = [
        \ 'inoremap <silent> <plug>(MUcompleteFwdKey) <right>',
        \ 'imap <right> <plug>(MUcompleteCycFwd)',
        \ 'let g:mucomplete#enable_auto_at_startup = 1'
        \ ]
  let l:cmd = ['edit Xout', 'call feedkeys("i\<right>ok", "tx")', 'norm! ZZ']
  call s:vim(l:vimrc, l:cmd)
  let l:output = join(readfile('Xout'))
  call assert_equal('ok', l:output)
  call delete('Xout')
endf

fun! Test_MU_issue_92()
  " Make sure that <cr> is defined before the autoload file is loaded.
  let l:vimrc = [
        \ 'imap <Plug>MyCR <Plug>(MUcompleteCR)',
        \ 'imap <cr> <Plug>MyCR'
        \ ]
  let l:cmd = ['edit Xout', 'set ft=ruby', 'call feedkeys("idef App\<cr>ok", "tx")', 'norm! ZZ']
  call s:vim(l:vimrc, l:cmd)
  let l:output = readfile('Xout')
  call assert_equal('def App', get(l:output, 0, 'NA'))
  call assert_equal('ok', get(l:output, 1, 'NA'))
  call delete('Xout')
endfun

fun! Test_MU_issues_95_Ctrl_N_smart_enter()
  " Vim does not always insert a new line after pressing Enter with the pop-up
  " menu visible. This function tests a situation is which Vim would not
  " normally insert a new line (so "ok" would end on the same line as
  " "hawkfish"), but µcomplete does, if g:mucomplete#smart_enter = 1.
  new
  let b:mucomplete_chain = ['keyn']
  MUcompleteAutoOff
  " let g:mucomplete#smart_enter = 1
  set completeopt=menuone
  call feedkeys("ahawkfish\<cr>hawk", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<c-p>fish\<cr>ok\<esc>", "tx")
  call assert_equal("hawkfish", getline(1))
  call assert_equal("hawkfish", getline(2))
  call assert_equal("ok", getline(3))
  bwipe!
  set completeopt&
endf

call RunBabyRun('MU')

