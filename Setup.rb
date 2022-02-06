#!/usr/bin/env ruby

def if_a_test ( r )
	if ENV.has_key? 'BBEDIT_ACTIVE_PROJECT'
		is_dm_proj_dir = r.split( "/" ).last == 'Droplet Maker'
		is_dm_active_proj = ENV['BBEDIT_ACTIVE_PROJECT'].split( '/' ).last.chomp == 'Droplet Maker.bbprojectd'
	end
	is_dm_proj_dir && is_dm_active_proj ? "#{r}test/" : r
end

a_script, drop_script = DATA.read.split( "##SPLIT HERE\n" )

test_root = `osascript -e $'#{a_script}' 'get_dir'`.chomp

proj_root = if_a_test( test_root )

exec "osascript -e $'#{a_script}' 'err_msg' > /dev/null" unless File.directory? test_root

Dir.chdir proj_root do
 	Dir.mkdir 'build' unless Dir.exist? 'build'
	return if File.exist? 'droplet_script.applescript'
	File.open( 'droplet_script.applescript', 'w' ){ | f | f.write drop_script }
	system "afplay '/System/Library/Sounds/Glass.aiff' 2> /dev/null"
end

__END__

on run(argv)
	if item 1 of argv is "err_msg"
		my err_msg()
	else if item 1 of argv is "get_dir"
		my get_dir()
	end if
end run

on err_msg()
	beep
	tell application "BBEdit" to display dialog "The Setup Droplet command expects a BBEdit project where it\'s first item in the side bar is a folder.\nIt will make a file \'droplet_script.applescript\', and a \'build\' folder in that project folder." with title "This is not a project." buttons {"OK"} default button "OK" with icon stop
end err_msg

on get_dir()
	tell application "BBEdit" to tell project document 1
		try 
			set _alias to file of item 1
			return POSIX path of _alias
		on error number -1728
			return
		end
	end tell
end get_dir

##SPLIT HERE
# Runs shell script in app bundle with parameters.
on run_shell_script(params)
	set _a to path to resource "/Scripts/shell_script"
	set shell_script to POSIX path of _a
	do shell script quoted form of shell_script & " " & params
end run_shell_script

on format_params(input_files)
	set params to ""
	repeat with input_file in input_files
		set param to POSIX path of input_file
		set params to params & " " & quoted form of param
	end repeat
	# Delete or comment out line to remove path and leave other params.
	path_to_app(params)
end format_params

# Sets the last parameter to the path of the app bundle.
on path_to_app(params)
	set home to POSIX path of ((path to me as text) & "::")
	set params to params & " " & quoted form of home
end path_to_app

# Runs if files are dropped on app bundle.
on open drop_files
	set params to format_params(drop_files)
	run_shell_script(params)
end open

# Runs if app bundle is double clicked.
on run
	set choosen_files to choose file with multiple selections allowed
	set params to format_params(choosen_files)
	run_shell_script(params)
end run