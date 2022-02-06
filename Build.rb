#!/usr/bin/env ruby

require 'fileutils'

def init()
	dir     = `osascript -e 'tell application "BBEdit"\nset _a to item 1 of project document 1\nset _p to POSIX path of _a\nend tell'`.chomp
	name    = ENV['BB_DOC_NAME']
	bundle  = "build/#{ name }".sub( /\.[a-z]+$/, '.app' )
	is_test = dir.split('/').last == 'Droplet Maker'
	return name ,"#{ dir }/test/", 'build/Test Me.app' if is_test
	return name, dir, bundle
end

def error_dialog( title, msg )
	re = /'/
	system "osascript -e $'#{DATA.read}' $'#{ title.gsub( re, %q(\\\') ) }' $'#{ msg.gsub( re, %q(\\\') ) }' &> /dev/null"
	false
end

def build_app( name, app_bundle )
	begin
		res_dir      = "#{ app_bundle }/Contents/Resources/"
		shell_script = "#{ res_dir }Scripts/shell_script"	
		system "osacompile -o '#{ app_bundle }' droplet_script.applescript"
		FileUtils.cp name, shell_script
		FileUtils.chmod 'u+x', shell_script
		true
	rescue Exception => e
		error_dialog( 'Error While Building Droplet', e.message )
	end
end

def check_if_setup( name )	
	has_target = -> {
		return false unless File.file?( name )
		return false unless File.open( name, &:gets ) =~ /^#![\w\/]+[ \w]/ 
		true
	}.call
	return true if has_target && Dir.exist?( 'build' ) && File.exist?( 'droplet_script.applescript' )
	msg   =  '• Did you run \'Droplet Maker > Setup\'?'
	msg   << '\n• The target script is not selected.\n• Ensure it has a proper shebang.' unless has_target
	msg   << '\n• The \'build\' directory is missing' unless Dir.exist?( 'build' )
	msg   << '\n• The \'droplet_script.applescript\' is missing.' unless File.exist?( 'droplet_script.applescript' )
	title =  'Check Build Requirments'
	error_dialog( title, msg )
end

def icns_from_png
	Dir.mkdir 'icon.iconset'
	begin		
		img_edit_coms = ['sips -z 16 16 icon.png --out icon.iconset/icon_16x16.png',
		'sips -z 32 32 icon.png --out icon.iconset/icon_16x16@2x.png',
		'sips -z 32 32 icon.png --out icon.iconset/icon_32x32.png',
		'sips -z 64 64 icon.png --out icon.iconset/icon_32x32@2x.png',
		'sips -z 128 128 icon.png --out icon.iconset/icon_128x128.png',
		'sips -z 256 256 icon.png --out icon.iconset/icon_128x128@2x.png',
		'sips -z 256 256 icon.png --out icon.iconset/icon_256x256.png',
		'sips -z 512 512 icon.png --out icon.iconset/icon_256x256@2x.png',
		'sips -z 512 512 icon.png --out icon.iconset/icon_512x512.png']
		
		img_edit_coms.each do | com |
			system com + '> /dev/null'
		end
	
		FileUtils.cp 'icon.png', 'icon.iconset/icon_512x512@2x.png'
		system 'iconutil -c icns icon.iconset'
		FileUtils.remove_dir 'icon.iconset'
		true
	rescue Exception => e
		error_dialog( 'Error While Making Icon', e.message )
	end
end

def cp_icns( app_bundle )
	begin
		icon_path = "#{ app_bundle }/Contents/Resources/"
		is_a_drop = File.foreach( 'droplet_script.applescript' ){ | l | puts true if l =~ /^on open drop_files$/ }
		icon      = is_a_drop ? "#{ icon_path }droplet.icns" : "#{ icon_path }applet.icns"
		FileUtils.mv 'icon.icns', icon
		true
	rescue Exception => e
		error_dialog( 'Error While Moving Icon Into App', e.message )
	end
end

name, pwd, app_bundle = init

Dir.chdir pwd do
 	exit unless check_if_setup( name )
	exit unless build_app( name, app_bundle )
	exit unless icns_from_png if File.exist? 'icon.png'
	exit unless cp_icns( app_bundle) if File.exist? 'icon.icns'
	system "afplay '/System/Library/Sounds/Glass.aiff' 2> /dev/null"
end

__END__

on run(argv)
	set _title to item 1 of argv
	set _msg to item 2 of argv
	tell application "BBEdit"
		beep 
		display dialog _msg with title _title buttons {"OK"} default button "OK" with icon stop
	end tell
end run