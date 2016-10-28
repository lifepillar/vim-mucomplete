# MUcomplete

Can't stand the dozen of MB of YouCompleteMe? Can't figure out the
correct settings to tame NeoComplete? D'you think AutoComplPop is an
old fashioned fusion group and Supertab a movie hero for children?

With a core well below 200 lines of code, µcomplete may be the
minimalistic autocompletion plugin you were looking for!

MUcomplete is an implementation of *chained (fallback) completion*,
whereby several completion methods are attempted one after another
until a result is returned.

Under the hood, µcomplete does nothing more than typing some
completion mappings for you (see `:h ins-completion`), either when you
press `<tab>`/`<s-tab>` or automatically while you are typing. You
choose which completion methods to use and in which order, and
µcomplete does the rest. It does no caching, no asynchronous
computation, no intelligent guessing. It just makes use of core Vim
features.


# Getting Started

MUcomplete requires Vim compiled with `+insert_expand` and `+menu`.
Vim 8 or later is recommended.

Installation does not require anything special. If you need help,
please read [How to Install]
(https://github.com/lifepillar/vim-mucomplete/wiki/How-to-Install).

No configuration is required, just start pressing `<tab>` or `<s-tab>`
to complete a word. If you want to enable automatic completion, put

```vim
let g:mucomplete#enable_auto_at_startup = 1
```

in your `.vimrc`.

MUcomplete is fully customizable. See `:help mucomplete.txt` for
detailed documentation.


**Important:** by itself, µcomplete does not provide any
“intellisense”/semantic completion. If you want that, you also need to
install suitable omni completion plugins for the languages you are
using (see the example below).


# MUcomplete in action

![µcomplete with jedi-vim](https://raw.github.com/lifepillar/Resources/master/mucomplete/jedi.gif)
![µcomplete with SQL](https://raw.github.com/lifepillar/Resources/master/mucomplete/sql.gif)

The example on the left shows µcomplete automatically offering
suggestions from [jedi-vim](https://github.com/davidhalter/jedi-vim),
which provides semantic completion for Python. Used settings:

```vim
set noshowmode shortmess+=c
setl infercase
setl completeopt-=preview
setl completeopt+=longest,menu,menuone
let g:jedi#popup_on_dot = 0  " It may be 1 as well
let g:mucomplete#enable_auto_at_startup = 1
```

The example on the right shows how different completion methods (omni
completion, keyword completion, file completion) are automatically
selected in different contexts. Used settings:

```vim
set showmode shortmess-=c
setl completeopt+=menu,menuone
setl infercase
let g:mucomplete#user_mappings = { 'sqla' : "\<c-c>a" }
let g:mucomplete#chains = { 'sql' : ['file', 'sqla', 'keyn'] }
let g:mucomplete#enable_auto_at_startup = 1
```


