# MUcomplete

Can't stand the dozen of MB of YouCompleteMe? Can't figure out the
correct settings to tame NeoComplete? D'you think AutoComplPop is an
old fashioned rock group and Supertab a movie hero for children?

MUcomplete (or µcomplete) may be the minimalistic autocompletion
plugin you were looking for!

MUcomplete does nothing more than typing some completion mappings for
you (see `:h ins-completion`), either when you press `<tab>`/`<s-tab>`
or automatically while you are typing. You choose which completion
methods to use and in which order, and µcomplete does the rest. It
does no caching, no asynchronous computation, no intelligent guessing.
It just makes use of built-in Vim features.

# Getting Started

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
using.

# MUcomplete in action

![µcomplete with jedi-vim](https://raw.github.com/lifepillar/Resources/master/mucomplete/mucomplete-jedi.gif)
![µcomplete with jedi-vim](https://raw.github.com/lifepillar/Resources/master/mucomplete/mucomplete-jedi.gif)


![µcomplete with jedi-vim](https://raw.github.com/lifepillar/Resources/master/mucomplete/mucomplete-jedi.gif)
![µcomplete with jedi-vim](https://raw.github.com/lifepillar/Resources/master/mucomplete/mucomplete-jedi.gif)

