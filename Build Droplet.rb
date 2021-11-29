#!/usr/bin/env ruby

require 'fileutils'

def setup()
	s = ENV['BB_DOC_PATH']
	n = ENV['BB_DOC_NAME']
	d = s.sub( n, '' )
	is_test = d.split('/')[-1] == 'Droplet Maker'
	return 'test/', 'Test Me.rb' ,'test/' if is_test
	return s, n, d
end

script, name, pwd = setup

app_path = "build/#{name}".sub( /\.[a-z]{2,4}\b/, '.app' )
res_dir = "#{app_path}/Contents/Resources/"
shell_script = "#{res_dir}Scripts/shell_script"

Dir.chdir pwd do
 	return `osascript -e $'#{DATA.read}'` unless Dir.exist? 'build'
	system "osacompile -o '#{app_path}' droplet_script.applescript"
	FileUtils.cp name, shell_script
	FileUtils.chmod 'u+x', shell_script
end

__END__

on run()
	tell application "BBEdit" to display dialog "Run \'Setup Droplet Script\' first." with title "Project not setup" buttons {"OK"} default button "OK" with icon stop
end run