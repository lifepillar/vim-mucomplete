# MUcomplete test folder

This folder contains:

- a Vim script to test the behaviour of µcomplete;
- an AppleScript script to profile µcomplete's performance.

To run the test suite, execute:

```
vim -u ../troubleshooting_vimrc.vim ./test_mucomplete.vim
```

then source the script with `:source %`.

The AppleScript script uses macOS's assistive technologies to send keystrokes to
Vim as if typed by a (fast) human typist (the speed can be set in the source
code).

To profile µcomplete, open `profile.applescript` in Script Editor and run it
(the script can be run from source). The script assumes that µcomplete is
installed in `~/.vim/pack/my/start/mucomplete`. Adjust the `MUcompleteFolder`
variable inside the script if necessary.

The result of the test is written into a `*.profile` file inside the `test`
folder.

**Note:** the test lasts a few minutes and during that time the system will be
unresponsive, because the script continuously sends keystrokes to the terminal.
If you need to interrupt the test, try to switch the focus away from
Terminal.app.

