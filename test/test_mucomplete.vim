let s:testdir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
execute 'lcd' s:testdir
execute 'source' s:testdir.'/test.vim'

fun! Test_MU_buffer_keyword_completion()
  new
  let b:mucomplete_chain = ['keyn']
  MUcompleteAutoOff
  set completeopt=menuone,noinsert,noselect
  imap <f5> <plug>(Foobar)
  call feedkeys("ajump ju", "tx")
  call feedkeys("a", "t!")
  call feedkeys("\<tab>\<esc>", "tx")
  call assert_equal("jump jump", getline(1))
  bwipe!
  set completeopt&
endf

fun! Test_MU_path_completion()
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

call RunBabyRun('MU')

