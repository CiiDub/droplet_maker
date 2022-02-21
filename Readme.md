# Droplet Maker

Droplet Maker is a BBEdit package for making simple droplets/applets from a  shell script. Anything with valid a shebang. Perl, Python, Ruby, PHP etc.

So it turns a target script named _Make Report.py_ into _Make Report.app_.

My definition of applet is an app that performs a simple ‘script’ like action when double clicked. Usually taking a file or files as input.

A droplet takes a file or files as input when they are dropped on it’s icon.

Though there are other, better solutions; Automator.app, [Shortcuts.app](https://support.apple.com/guide/shortcuts-mac/intro-to-shortcuts-apdf22b0444c/mac), or [Platypus.app](https://github.com/sveinbjornt/Platypus), I wanted to easily use source-control along with other workflow nicesties & features I’ve become accustomed to in BBEdit.

Copy & pasting a script into an Automator action really sucks after a while. 

I tried to make this a little more robust then the finicky little package that I’ve been using for a while. I’m sure that there are a thousand edge cases that I haven’t thought of. Give it a try but keep in mind this is not a professional solution.

## Working with this Project

1) Clone this repository to a safe place.

2) Run ```rake install``` from the command line while in the repository directory.

### Rake Commands
__rake install__  This installs this project as a BBEdit package in  _~/Library/Application Support/BBEdit/Packages/_ as _Droplet Maker.bbpackage_.

__rake uninstall__ Removes the package.

__rake test:cleanup__ Removes the  _build/_ directory & the file _droplet\_script.applescript_ from the projects _test/_ directory.

## Use
This package only works with a BBEdit project. The project must have a root directory. More specifically the directory that houses your target script (a.k.a. Make Report.py) must be the first item in the project. 

BBEdit “insta” projects -_which are made by dropping a project’s directory on the BBEdit icon_- are also supported.

This package consists of two commands, __Setup__ & __Build__.

You are meant to run __Setup__ once & __Build__ after you make changes.

### Setup

__Setup__ makes a _build/_ directory & a file named _droplet\_script.applescript_.

The _build/_ directory is the where your applet is saved when you run __Build__.

The _droplet\_script.applescript_ defines the input of the final applet or droplet. I tried to define some helpful and sane defaults but you likely want to edit this file.

By default _droplet\_script.applescript_ is setup to act as a droplet & applet which ask for file(s) after being launched.

#### It includes these five AppleScript handlers.
- `on run`\
	Commands in this handler run when you double click the applet. By default it asks for files via a dialog box & runs the target script with the file paths as parameters.
	
	If you want to define a different kind of input, such as a user provided string, that would likely happen in this handler.

- `on open`\
	This is what happens when a file is dropped on the droplet icon. It’s default setup works just like `on run`, except the files are passed in through the `drop\_files` parameter.
	
	Either `on run` or `on open` must be present. Both are available by default, allowing the script to be an applet & droplet.
	
- `on run_shell_script`\
	This handler is called from both `on run` & `on open`. It calls your target script. It takes a string as a space separated parameter list. It then passes this string to your target script as if it’s a shell command (it’s in fact calling an executable copy of your script from inside the app bundle).
	
	It is required.
	
- `on format_params`\
	This is a “helper” called by both `on run` & `on open`. It takes a list of AppleScript file objects & returns a string containing the files paths. It also included a path to the applets enclosing directory by calling the `on path_to_app` handler.
	
	You can easily edit `on format_params` to make that optional.
	
- `on path_to_app`\
	This handler takes a sting, & appends the path to the applets parent directory. So it takes the parameters defined earlier for the target script & adds the path back to the applet to the end of the string.

### Build

Run the __build__ command while your target script is selected. If it is not selected you will get an error. It will create a an app bundle with the same name as the selected target file but with the .app extension in _build/_.

It is actually using _droplet\_script.applescript_ as a parameter for `osacompile` to make the app bundle in the _build/_ directory. Your target script is made into an executable & copied into the app bundle. You can find it & it’s AppleScript companion in _/Project Folder/build/Project.app/Contents/Resources/Scripts/_.

- _main.scpt_ is is the “compiled” version of _droplet\_script.applescript_.

- _shell\_script_ is an executable copy of your target script.

__Build__ will also look for a image called _icon.png_ in your project directory. It will use this image, which should be 1024 by 1024 pixels, to make a custom icon for your applet or droplet.

_Icon.png_ is not required. MacOS will provide a default icon.

### Test Directory

If you want to make changes to your copy of Droplet Maker, I suggest making a BBEdit project file for it.

Droplet Maker will check if it is being called from a project called _Droplet Maker_. If this is the case it will use this directory as the project root directory. __Setup__ & __Build__ will run from here.

It includes a test icon _icon.png_, a target script _Test Me.rb_ & text file to test if an incorrect file is selected _no\_shebang.txt_.

These files represent something pretty close to minimum requirements for Droplet Maker to work.

This is most useful if you are making changes to the package. It is also a good way to give Droplet Maker a dry run.

### Etc.

I used Droplet Maker for this little [Finder button app](https://github.com/CiiDub/new_file_finder_button). It may be helpful as a simple example.

