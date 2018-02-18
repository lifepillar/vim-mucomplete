" To run the tests:
"
" 1. vim -u ../troubleshooting_vimrc.vim test_mucomplete.vim
" 2. :source %
"
" TODO: use option_save() and option_restore() when implemented
let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'


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

call RunBabyRun('MU')

