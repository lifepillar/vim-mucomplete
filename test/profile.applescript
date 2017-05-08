property name : "MUcompleteTest"
property id : "me.lifepillar.MUcompleteTest"
property version : "0.0.1"
property TopLevel : me

property HOME : missing value
property MUcompleteFolder : missing value
property TestFolder : missing value
-- See http://macscripter.net/viewtopic.php?id=39009 (note that this is specific to my own keyboard layout)
property charList : {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "+", "=", linefeed}
property codeList : {29, 18, 19, 20, 21, 23, 22, 26, 28, 25, 47, 24, 24, 76}
property modList : {"", "", "", "", "", "", "", "", "", "", "", "shift", "", ""}

on split(theText, theDelim)
	set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, theDelim}
	set theResult to the text items of theText
	set AppleScript's text item delimiters to tid
	return theResult
end split

on join(theList, theDelim)
	set {tid, AppleScript's text item delimiters} to {AppleScript's text item delimiters, theDelim}
	set theResult to theList as text
	set AppleScript's text item delimiters to tid
	return theResult
end join

on getFrontApp() -- Adapted from http://macscripter.net/viewtopic.php?id=22375
	set pathItems to split(path to frontmost application as text, ":")
	if item -1 of pathItems is "" then
		set appName to item -2 of pathItems
	else
		set appName to item -1 of pathItems
	end if
	if (appName contains ".") then
		return join(items 1 thru -2 of split(appName, "."), ".")
	end if
	return appName
end getFrontApp

on pad(n)
	if n < 10 then
		"0" & (n as text)
	else
		n as text
	end if
end pad

on timestamp()
	local d
	set d to current date
	((year of d) & (month of d) & (day of d) & "-" & my pad((time of d) div 3600) & my pad((time of d) div 60 mod 60)) as text
end timestamp

on readUTF8File(thePath)
	read (POSIX file (POSIX path of thePath) as alias) from 1 to eof as Çclass utf8È
end readUTF8File

on pressKey(c)
	repeat with i from 1 to count my charList
		if item i of my charList is c then
			if item i of my modList is "shift" then
				tell application "System Events" to key code (item i of my codeList) using shift down
			else
				tell application "System Events" to key code (item i of my codeList)
			end if
			return
		end if
	end repeat
	tell application "System Events" to keystroke c
end pressKey

on type(theText, wpm)
	local d
	set d to 60 / (5 * wpm)
	repeat with i from 1 to count theText
		if getFrontApp() is not "Terminal" then
			error "Focus lost"
		end if
		my pressKey(character i of theText)
		delay d
	end repeat
end type

on prepareBuffer(commands)
	tell application "System Events"
		keystroke "[" using control down -- Esc
		keystroke ":enew!" & linefeed
		repeat with cmd in commands
			keystroke ":" & cmd & linefeed
		end repeat
		keystroke "i"
	end tell
end prepareBuffer

-- Main

on run
	set HOME to POSIX path of (path to home folder from user domain as alias)
	set MUcompleteFolder to HOME & ".vim/pack/my/start/mucomplete/" -- CHANGE AS NEEDED
	try
		POSIX file MUcompleteFolder as alias
	on error
		display dialog Â
			("The following path does not exist: " & linefeed & linefeed & MUcompleteFolder as text) & linefeed & linefeed & Â
			"Please adjust the value of MUcompleteFolder in the script and try again." buttons {"Got it"} Â
			default button "Got it" cancel button "Got it" with icon stop
	end try
	set TestFolder to MUcompleteFolder & "test/"
	
	display dialog Â
		"This test lasts several minutes and the system will be unresponsive during that time." & linefeed & linefeed & Â
		"Do you really want to continue?" buttons {"Cancel", "Continue"} default button "Cancel" cancel button Â
		"Cancel" with title "MUcomplete Test" with icon caution
	
	-- Open a new terminal window and run Vim
	tell application "Terminal"
		do script "cd" & space & quoted form of TestFolder & space & Â
			"&& vim -u ../troubleshooting_vimrc.vim" & space & Â
			"--cmd 'profile start mucomplete-" & my timestamp() & ".profile'" & space & Â
			"--cmd 'profile! file */autoload/mucomplete.vim'" & space & Â
			"-c 'MUcompleteAutoOn'" & space & Â
			"-c 'set noshowmode shortmess+=c'"
		activate
	end tell
	
	Test0()
	Test1()
	Test2()
	
	tell application "System Events"
		keystroke "[" using control down -- Esc
		keystroke "ZQ" -- Quit Vim
	end tell
	return
end run


-- Tests

on Test0() -- Warm up :)
	set s to "jump jump jump jump!"
	my prepareBuffer({})
	my type(s, 60)
end Test0

on Test1()
	my prepareBuffer({"set ft=vim", "setl nospell formatoptions="})
	my type(readUTF8File(my MUcompleteFolder & "plugin/mucomplete.vim"), 212)
end Test1


on Test2()
	my prepareBuffer({"set ft=text", "setl spell spelllang=en"})
	my type(readUTF8File(my MUcompleteFolder & "Readme.md"), 500)
end Test2
