#!/usr/bin/env ruby

a_script = DATA.read
proj_root = `osascript -e $'#{a_script}' 'get_dir'`.chomp
unless File.directory? proj_root
	`osascript -e $'#{a_script}' 'err_msg'`
	return
end

dropscript = <<HEREDOC
# Runs shell script in app bundle with parameters.
on run_shell_script(params)
	set _a to path to resource "/Scripts/shell_script"
	set shell_script to POSIX path of _a
	do shell script quoted form of shell_script & " " & params
end run_shell_script

on format_params(input_files)
	set params to ""
	repeat with input_file in input_files
		set param to POSIX path of dropfile
		set params to params & " " & quoted form of param
	end repeat
end format_params

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
HEREDOC

Dir.chdir proj_root do
 	Dir.mkdir 'build' unless Dir.exist? 'build'
	
	File.open 'droplet_script.applescript', 'w' do | f |
		f.write dropscript
	end unless File.exist? 'droplet_script.applescript'
end

# AppleScript ↓
__END__
on run(argv)
	if item 1 of argv is "err_msg"
		my err_msg()
	else if item 1 of argv is "get_dir"
		my get_dir()
	end if
end run

on err_msg()
	tell application "BBEdit" to display dialog "The Setup Droplet command expects a project with a main directory. It will make a file \'droplet_script.applescript\', and a \'build\' folder in that project folder." with title "This is not a project." buttons {"OK"} default button "OK" with icon stop
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