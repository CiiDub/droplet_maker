#!/usr/bin/env ruby

pwd = ARGV[-1]
sel_file = ARGV[0]

`osascript -e 'display dialog "File Path: #{sel_file}/n Working Directing: #{pwd}" with title "It Worked"'`

Dir.chdir "#{pwd}.." do
	File.open( 'I think it worked.txt', 'w' ) { |f| f.write sel_file }
end
