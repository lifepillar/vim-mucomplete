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
`+menu`. Automatic completion is available in Vim 7.4 or later.
MUcomplete is developed and tested on Vim 8. It works in NeoVim as
well.

Installation does not require anything special. If you need help,
please read [How to Install]
(https://github.com/lifepillar/vim-mucomplete/wiki/How-to-Install).

Mandatory Vim settings:

```vim
  set completeopt+=menu,menuone
```

Other recommended settings:

```
  set shortmess+=c
  " For automatic completion, you most likely want one of:
  set completeopt+=noinsert " or
  set completeopt+=noinsert,noselect
```

No other configuration is needed. Just start pressing `<tab>` or
`<s-tab>` to complete a word. If you want to enable automatic
completion, put

```vim
let g:mucomplete#enable_auto_at_startup = 1
```

in your `.vimrc`.

When the pop-up menu is visible, you may cycle back and forth through
the completion methods in the current completion chain by pressing
`<c-h>` and `<c-l>`, respectively.

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
set completeopt-=preview
set completeopt+=longest,menu,menuone,noinsert,noselect
let g:jedi#popup_on_dot = 0  " It may be 1 as well
let g:mucomplete#enable_auto_at_startup = 1
```

The example on the right shows how different completion methods (omni
completion, keyword completion, file completion) are automatically
selected in different contexts. Used settings:

```vim
set showmode shortmess-=c
set completeopt+=menu,menuone,noinsert,noselect
let g:mucomplete#user_mappings = { 'sqla' : "\<c-c>a" }
let g:mucomplete#chains = { 'sql' : ['file', 'sqla', 'keyn'] }
let g:mucomplete#enable_auto_at_startup = 1
```

# Compatibility

See `:help mucomplete-compatibility`.
