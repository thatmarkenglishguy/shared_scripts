::Setup the symlinks used by Msys

@setlocal

@openfiles 1>NUL 2>&1
@set _ISADMIN=%errorlevel%
@if %_ISADMIN% NEQ 0 goto :NotElevated

@if NOT EXIST c:\msys64 goto :NoMsys64

::MKLINK [[/D] | [/H] | [/J]] Link Target
::
::        /D      Creates a directory symbolic link.  Default is a file
::                symbolic link.
::        /H      Creates a hard link instead of a symbolic link.
::        /J      Creates a Directory Junction.
::        Link    Specifies the new symbolic link name.
::        Target  Specifies the path (relative or absolute) that the new link

@echo Creating links
@mklink c:\msys64\etc\markebash.rc %~d0\code\shscripts\markebash.rc
@mklink c:\msys64\etc\markebash.rc %~d0\code\shscripts\bash_shscripts\pathfunctions
::/etc/
::#lrwxrwxrwx 1 mark None    30 Feb 15  2017 markebash.rc -> /c/code/shscripts/markebash.rc
::#rwxrwxrwx 1 mark None    31 Feb 15  2017 pathfunctions -> /c/code/shscripts/pathfunctions

::/etc/profile.d
::lrwxrwxrwx 1 mark None   31 Feb 15  2017 extrapaths.sh -> /c/code/shscripts/extrapaths.sh
::lrwxrwxrwx 1 mark None   30 Feb 15  2017 markebash.sh -> /c/code/shscripts/markebash.sh

@mklink c:\msys64\etc\profile.d\extrapaths.sh %~d0\code\shscripts\extrapaths.sh
@mklink c:\msys64\etc\profile.d\markebash.sh %~d0\code\shscripts\markebash.sh

:: Shouldn't need to do this as can just check out the file directly into ${HOME}
::@mklink c:\msys64\home\%USERNAME%\.git-completion.bash %~d0\code\thirdparty\shscripts\git-completion.bash

@goto :Finish

:NoMsys64
@echo Msys64 not installed (expected to find in c:\msys64). Please install before running this script.
@goto :Finish

:NotElevated
@echo You are not running with elevated priviliges. Please run from an elevated command prompt.
@goto :Finish

:Finish

@endlocal
