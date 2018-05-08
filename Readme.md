**NOTE: v1.0.0 introduces some backward incompatible changes. Please review the docs.**

>We're coming down to the ground
>
>There's no better place to go
>
>(Peter Gabriel)

# What is it?

MUcomplete is a minimalist autocompletion plugin for Vim.

MUcomplete is an implementation of *chained (fallback) completion*, whereby
several completion methods are attempted one after another until a result is
returned.

Under the hood, MUcomplete does nothing more than typing some completion
mappings for you, either when you press `<tab>`/`<s-tab>` or automatically
while you are typing. You choose which completion methods to use and in which
order, and MUcomplete does the rest. It does no caching, no asynchronous
computation, no intelligent guessing. It just makes use of core Vim features.

MUcomplete brings Vim completion down to earth again.


# Getting Started

MUcomplete requires Vim 7.2 compiled with `+insert_expand` and `+menu`.
Automatic completion works in Vim 7.4.775 or later (Vim 7.4.784 or later
recommended). MUcomplete is developed and tested on Vim 8. NeoVim is
supported, too.

Installation does not require anything special. If you need help, please read
[How to Install](https://github.com/lifepillar/vim-mucomplete/wiki/How-to-Install).

Mandatory Vim settings:

```vim
  set completeopt+=menuone
```

For automatic completion, you also need one of the following:

```vim
  set completeopt+=noselect
  set completeopt+=noinsert
```

Other recommended settings:

```vim
  set shortmess+=c   " Shut off completion messages
  set belloff+=ctrlg " If Vim beeps during completion
```

No other configuration is needed. Just start pressing `<tab>` or `<s-tab>` to
complete a word. If you want to enable automatic completion at startup, put

```vim
let g:mucomplete#enable_auto_at_startup = 1
```

in your `.vimrc`. Automatic completion may be enabled and disabled at any time
with `:MUcompleteAutoToggle`.

**Note:** *MUcomplete maps `<tab>`, `<s-tab>`, `<c-j>`, `<c-h>`, `<cr>`,
`<c-e>`, `<c-y>` in Insert mode by default.  If you prefer to provide your own
mappings, you may set `g:mucomplete#no_mappings` to `1` in your `vimrc`. Read
the documentation for more options and for hints about making MUcomplete work
with plugins having conflicting mappings.*

By default, MUcomplete attempts:

1. path completion, if the text in front of the cursor looks like a path;
2. omni-completion, if enabled in the current buffer;
3. buffer keyword completion;
4. dictionary completion, if a dictionary is set for the current buffer;
5. spelling completion, if `'spell'` is on and `'spelllang'` is set;

in this order (this is called a *completion chain*). At the first successful
attempt, the pop-up menu shows the results. When the pop-up menu is visible,
you may cycle back and forth through the completion chain and try different
completion methods by pressing `<c-h>` and `<c-j>`, respectively. See below
for an example.

MUcomplete is fully customizable. See `:help mucomplete.txt` for detailed
documentation.

**Important:** by itself, MUcomplete does not provide any
“intellisense”/semantic completion. If you want that, you also need to install
suitable omni completion plugins for the languages you are using (see the
examples below).


# MUcomplete in action

With jedi-vim (Python)     |  With SQL (Vim)
:-------------------------:|:-------------------------:
![](https://raw.github.com/lifepillar/Resources/master/mucomplete/jedi.gif) | ![](https://raw.github.com/lifepillar/Resources/master/mucomplete/sql.gif)

The first example shows MUcomplete automatically offering suggestions from
[jedi-vim](https://github.com/davidhalter/jedi-vim), which provides semantic
completion for Python. Used settings:

```vim
set completeopt-=preview
set completeopt+=longest,menuone,noselect
let g:jedi#popup_on_dot = 0  " It may be 1 as well
let g:mucomplete#enable_auto_at_startup = 1
```

The second example shows how different completion methods (omni completion,
keyword completion, file completion) are automatically selected in different
contexts. Used settings:

```vim
set completeopt+=menuone,noselect
let g:mucomplete#user_mappings = { 'sqla' : "\<c-c>a" }
let g:mucomplete#chains = { 'sql' : ['file', 'sqla', 'keyn'] }
```

With clang_complete        |  Extending completion
:-------------------------:|:-------------------------:
![](https://raw.github.com/lifepillar/Resources/master/mucomplete/clang.gif) | ![](https://raw.github.com/lifepillar/Resources/master/mucomplete/ctrlx-ctrln.gif)

The example above shows MUcomplete used with
[clang-complete](https://github.com/Rip-Rip/clang_complete). You may also see
how it is possible to switch between different completion methods (omni
completion and keyword completion in this case) when the pop-up menu is visible,
using `<c-j>` and `<c-h>` (pay attention when `lo` is completed). Relevant
settings:

```vim
set noinfercase
set completeopt-=preview
set completeopt+=menuone,noselect
" The following line assumes `brew install llvm` in macOS
let g:clang_library_path = '/usr/local/opt/llvm/lib/libclang.dylib'
let g:clang_user_options = '-std=c++14'
let g:clang_complete_auto = 1
let g:mucomplete#enable_auto_at_startup = 1
```

The last example shows how the current completion can be extended with words
following the previous expansion in other contexts. Relevant settings:

```vim
imap <expr> <down> pumvisible() ? "\<plug>(MUcompleteExtendFwd)" : "\<down>"
```

In the example, `<tab>` was typed to trigger a completion, then `<down>` was
pressed repeatedly to extend the completion. To my knowledge, MUcomplete is the
only completion plugin that streamlines such Vim feature.



# Compatibility

See `:help mucomplete-compatibility`.


# Troubleshooting

See `:help mucomplete-troubleshooting`.
