#!/usr/bin/env ruby

require 'fileutils'

def init()
	path    = ENV['BB_DOC_PATH']
	name    = ENV['BB_DOC_NAME']
	dir     = path.sub( name, '' )
	bundle  = "build/#{name}".sub( /\.[a-z]+$/, '.app' )
	is_test = dir.split('/').last == 'Droplet Maker'
	return name ,"#{dir}/test/", 'build/Test Me.app' if is_test
	return name, dir, bundle
end

def error_dialog( title, msg )
	print msg
	rx = /'/
	system "osascript -e $'#{DATA.read}' $'#{ title.gsub( rx, %q(\\\') ) }' $'#{ msg.gsub( rx, %q(\\\') ) }' > /dev/null"
	false
end

def build_app( name, app_bundle )
	begin
		res_dir      = "#{app_bundle}/Contents/Resources/"
		shell_script = "#{res_dir}Scripts/shell_script"	
		system "osacompile -o '#{app_bundle}' droplet_script.applescript"
		FileUtils.cp name, shell_script
		FileUtils.chmod 'u+x', shell_script
		true
	rescue Exception => e
		error_dialog( 'Error While Building Droplet', e.message )
	end
end

def check_if_setup( name )
	has_shebang = -> do
		return false unless File.exists? name
		return false unless File.open( name, &:gets ) =~ /^#![\w\/]+[ \w]/ 
		true
	end
	return true if has_shebang.call && Dir.exist?( 'build' )
	title = 'Check Build Requirments'
	msg   = '• Run \'Droplet Maker > Setup\' first.\n• Be sure to select the target script.\n• Ensure it has a proper shebang: \'#!usr/bin/...\'.'
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
		icon_path = "#{app_bundle}/Contents/Resources/"
		icon      = Dir["#{icon_path}*.icns"].first
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
	exit unless cp_icns( app_bundle ) if File.exist? 'icon.icns'
end

__END__

on run(argv)
	set _title to item 1 of argv
	set _msg to item 2 of argv
	tell application "BBEdit" to display dialog _msg with title _title buttons {"OK"} default button "OK" with icon stop
end run