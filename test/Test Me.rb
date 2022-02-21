#!/usr/bin/env ruby

pwd = ARGV.last #The working directory for your applet.
sel_file = ARGV.first #The selected files, either selected through a dialog or dropped on the applet.

# An example dialog to show results.
`osascript -e 'display dialog "File Path: #{sel_file}\nWorking Directing: #{pwd}" with title "It Worked"'`

# This writes a file in the parent directory of the applets root. The text file lists the selected files.
Dir.chdir "#{pwd}.." do
	File.open( 'I think it worked.txt', 'w' ) { |f| f.write sel_file }
end
