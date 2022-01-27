#!/usr/bin/env ruby

pwd = ARGV.last
sel_file = ARGV.first

`osascript -e 'display dialog "File Path: #{sel_file}\nWorking Directing: #{pwd}" with title "It Worked"'`

Dir.chdir "#{pwd}.." do
	File.open( 'I think it worked.txt', 'w' ) { |f| f.write sel_file }
end
