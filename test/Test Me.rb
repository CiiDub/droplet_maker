#!/usr/bin/env ruby

bundle = ARGV[-1]
sel_file = ARGV[0]

`osascript -e 'display dialog "File Path: #{sel_file} Script Path: #{bundle}" with title "It Worked"'`

Dir.chdir "#{bundle}../.." do
	File.open( 'I think it worked.txt', 'w' ) { |f| f.write sel_file }
end
