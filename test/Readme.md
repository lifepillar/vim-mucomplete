# Profile script for µcomplete

This AppleScript script can be used to profile µcomplete. It uses macOS's
assistive technologies to send keystrokes to Vim as if typed by a (fast)
human typist.

To execute the test, open `profile.applescript` in Script Editor and run it (the
script can be run from source). The script assumes that µcomplete is installed
in `~/.vim/pack/my/start/mucomplete`. Adjust the `MUcompleteFolder` variable
inside the script if necessary.

The result of the test is written into a `.profile` file inside the `test`
folder.

**Note:** the test lasts a few minutes and cannot be interrupted, because the
script continuously sends keystrokes to the current foremost application. For
this reason, do **not** switch the focus away from Terminal until the test is
over!
