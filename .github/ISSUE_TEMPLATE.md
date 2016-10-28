For bug reports only, please provide the following details:

- [ ] I have followed the instructions in `:help mucomplete-troubleshooting`.
- [ ] Output of `echo g:mucomplete#chains`: …
- [ ] Output of `setl completeopt`: …
- [ ] MUcomplete settings in my `.vimrc`, if any: …

If your problem has to do with specific completion methods, please provide the
output of the relevant settings among the following:

- (`'spel'`) `setl spell? spelllang`
- (`'dict'`) `setl dictionary spell? spelllang`
- (`'tags'`) `setl tags` and `echo tagfiles()`
- (`'omni`') `setl ft omnifunc`
- (`'user'`) `setl ft completefunc`
- (`'thes'`) `setl thesaurus`
- (`'defs'`, `'incl'`) `setl ft include path`
- (`'c-n'`, `'c-p'`, `'line'`) `setl ft cpt inc pa dict tsr spell? spl tags`
                                    and `echo tagfiles()`

Delete the parts of this text that are not relevant to your issue.
