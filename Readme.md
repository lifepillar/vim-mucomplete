**NOTE: v1.0.0 introduces some backward incompatible changes. Please review the docs.**

>We're coming down to the ground
>
>There's no better place to go
>
>(Peter Gabriel)

# MUcomplete

Can't stand the dozen of MB of YouCompleteMe? Can't figure out the
correct settings to tame NeoComplete? D'you think AutoComplPop is an
old fashioned fusion group and Supertab a movie hero for children?

With less code than documentation, µcomplete may be the minimalistic
autocompletion plugin you were looking for!

MUcomplete is an implementation of *chained (fallback) completion*,
whereby several completion methods are attempted one after another
until a result is returned. MUcomplete brings Vim completion down to
earth again.

Under the hood, µcomplete does nothing more than typing some
completion mappings for you, either when you press `<tab>`/`<s-tab>`
or automatically while you are typing. You choose which completion
methods to use and in which order, and µcomplete does the rest. It
does no caching, no asynchronous computation, no intelligent guessing.
It just makes use of core Vim features.


# Getting Started

MUcomplete requires Vim 7.2 compiled with `+insert_expand` and
`+menu`. Automatic completion works in Vim 7.4.775 or later (Vim
7.4.784 or later recommended). MUcomplete is developed and tested on
Vim 8. NeoVim is supported, too.

Installation does not require anything special. If you need help,
please read [How to Install](https://github.com/lifepillar/vim-mucomplete/wiki/How-to-Install).

Mandatory Vim settings:

```vim
  set completeopt+=menuone
```

For automatic completion, you also need to put these in your `vimrc`:

```vim
  set completeopt+=noinsert
  inoremap <expr> <c-e> mucomplete#popup_exit("\<c-e>")
  inoremap <expr> <c-y> mucomplete#popup_exit("\<c-y>")
  inoremap <expr>  <cr> mucomplete#popup_exit("\<cr>")
```

Other recommended settings:

```vim
  set shortmess+=c
  set completeopt+=noselect
```

No other configuration is needed. Just start pressing `<tab>` or
`<s-tab>` to complete a word. If you want to enable automatic
completion at startup, put

```vim
let g:mucomplete#enable_auto_at_startup = 1
```

in your `.vimrc`. Automatic completion may be enabled and disabled at
any time with `:MUcompleteAutoToggle`.

When the pop-up menu is visible, you may cycle back and forth through
the completion methods in the current completion chain by pressing
`<c-h>` and `<c-j>`, respectively. See below for an example.

MUcomplete is fully customizable. See `:help mucomplete.txt` for
detailed documentation.

**Important:** by itself, µcomplete does not provide any
“intellisense”/semantic completion. If you want that, you also need to
install suitable omni completion plugins for the languages you are
using (see the examples below).


# MUcomplete in action

![µcomplete with jedi-vim](https://raw.github.com/lifepillar/Resources/master/mucomplete/jedi.gif)
![µcomplete with SQL](https://raw.github.com/lifepillar/Resources/master/mucomplete/sql.gif)

The first example shows µcomplete automatically offering suggestions from
[jedi-vim](https://github.com/davidhalter/jedi-vim), which provides semantic
completion for Python. Used settings:

```vim
set noshowmode shortmess+=c
set completeopt-=preview
set completeopt+=longest,menuone,noinsert,noselect
let g:jedi#popup_on_dot = 0  " It may be 1 as well
let g:mucomplete#enable_auto_at_startup = 1
```

The second example shows how different completion methods (omni completion,
keyword completion, file completion) are automatically selected in different
contexts. Used settings:

```vim
set showmode shortmess-=c
set completeopt+=menuone,noinsert,noselect
let g:mucomplete#user_mappings = { 'sqla' : "\<c-c>a" }
let g:mucomplete#chains = { 'sql' : ['file', 'sqla', 'keyn'] }
let g:mucomplete#enable_auto_at_startup = 1
```

![µcomplete with clang-complete](https://raw.github.com/lifepillar/Resources/master/mucomplete/cpp.gif)

The example above shows µcomplete used with
[clang-complete](https://github.com/Rip-Rip/clang_complete). You may also see
how it is possible to switch between different completion methods (omni
completion and keyword completion in this case) when the pop-up menu is visible,
using `<c-j>` and `<c-h>` (pay attention when `lo` is completed). Relevant
settings:

```vim
set noshowmode shortmess+=c
set noinfercase
set completeopt-=preview
set completeopt+=menuone,noinsert,noselect
" The following line assumes `brew install llvm` in macOS
let g:clang_library_path = '/usr/local/opt/llvm/lib/libclang.dylib'
let g:clang_user_options = '-std=c++14'
let g:clang_complete_auto = 1
let g:mucomplete#enable_auto_at_startup = 1
```


# Compatibility

See `:help mucomplete-compatibility`.


# Troubleshooting

See `:help mucomplete-troubleshooting`.
