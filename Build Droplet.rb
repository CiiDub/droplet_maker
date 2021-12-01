#!/usr/bin/env ruby

require 'fileutils'

def setup()
	s = ENV['BB_DOC_PATH']
	n = ENV['BB_DOC_NAME']
	d = s.sub( n, '' )
	is_test = d.split('/')[-1] == 'Droplet Maker'
	return 'Test Me.rb' ,'test/' if is_test
	return n, d
end

name, pwd = setup
app_bundle = "build/#{name}".sub( /\.[a-z]{2,4}\b/, '.app' )

def build_app( name, app_bundle )
	res_dir = "#{app_bundle}/Contents/Resources/"
	shell_script = "#{res_dir}Scripts/shell_script"	
	system "osacompile -o '#{app_bundle}' droplet_script.applescript"
	FileUtils.cp name, shell_script
	FileUtils.chmod 'u+x', shell_script
end

def check_if_setup
	unless Dir.exist? 'build'
		system "osascript -e $'#{DATA.read}'"
		exit	
	end
end

def icns_from_png
	Dir.mkdir 'icon.iconset'
	system 'sips -z 16 16     icon.png --out icon.iconset/icon_16x16.png'
	system 'sips -z 32 32     icon.png --out icon.iconset/icon_16x16@2x.png'
	system 'sips -z 32 32     icon.png --out icon.iconset/icon_32x32.png'
	system 'sips -z 64 64     icon.png --out icon.iconset/icon_32x32@2x.png'
	system 'sips -z 128 128   icon.png --out icon.iconset/icon_128x128.png'
	system 'sips -z 256 256   icon.png --out icon.iconset/icon_128x128@2x.png'
	system 'sips -z 256 256   icon.png --out icon.iconset/icon_256x256.png'
	system 'sips -z 512 512   icon.png --out icon.iconset/icon_256x256@2x.png'
	system 'sips -z 512 512   icon.png --out icon.iconset/icon_512x512.png'
	FileUtils.cp 'icon.png', 'icon.iconset/icon_512x512@2x.png'
	system 'iconutil -c icns icon.iconset'
	FileUtils.remove_dir 'icon.iconset'
end

def cp_icns( app_bundle )
	icon = "#{app_bundle}/Contents/Resources/droplet.icns"
	FileUtils.cp 'icon.icns', icon
end

Dir.chdir pwd do
 	check_if_setup 
	build_app( name, app_bundle )
	icns_from_png if File.exist? 'icon.png'
	cp_icns( app_bundle ) if File.exist? 'icon.icns'
end

__END__

on run()
	tell application "BBEdit" to display dialog "Run \'Setup Droplet Script\' first." with title "Project not setup" buttons {"OK"} default button "OK" with icon stop
end run