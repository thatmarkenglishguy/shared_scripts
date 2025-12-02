:: Setup all the things
@set SCRIPT_DIR=%~dp0
@set PATHBATSDIR=
@set PATHBINDIR=
@set OLD_PATH=%PATH%

:: You might have to do this line yourself if you've checked out this repo inside WSL
:: You might see a CreateProcessEntryCommon error but can ignore it
@for /f %%u in ('wsl.exe whoami') do @(
  @set WSLUSER=%%u
  @goto founduser
)

@echo No wsl user for you >&2
@goto exit

:founduser
@echo Found WSLUSER: %WSLUSER% >&2
@if not exist %USERPROFILE%\wslme mklink /D %USERPROFILE%\wslme \\wsl.localhost\Ubuntu\home\%WSLUSER%

:: Import all the standard things, including:
:: * Python3
:: * Notepad++
:: * SysInternals
winget import --accept-source-agreements --accept-package-agreements winget_imports_setup.json

:: Install PyWin32
py -m pip install --upgrade pywin32

:: Sort out the bats path
@for %%d in (%~dp0..\..) do @set BATSDIR=%%~fd\bats

:: Check for BATSDIR in PATH
set PATH| findstr /C:"%BATSDIR%" >NUL

if %ERRORLEVEL% NEQ 0 @goto addbats
@goto gotbats

:addbats
:: Check for ; at the end of the PATH
@set PATHBATSDIR=%BATSDIR%
@set PATH| findstr /E /C:";" >NUL
@if %ERRORLEVEL% EQU 1 @set PATHBATSDIR=;%PATHBATSDIR%
@echo Adding %BATSDIR% to PATH... >&2
@echo We used to edit the path using setx but that now truncates to 1024 characters which isn't a lot. >&2
@echo Instead edit the Environment Variables directly for %USER% by running: >&2
@echo rundll32 sysdm.cpl,EditEnvironmentVariables >&2
@echo and set the PATH to: >&2
@echo %PATH%%PATHBATSDIR%
::setx PATH "%PATH%%PATHBATSDIR%"
set PATH=%PATH%%PATHBATSDIR%


:gotbats
:: Sort out a place to put random binaries
@set BINDIR=c:\bin
@if not exist %BINDIR% mkdir %BINDIR%

:: Check for BINDIR in PATH
@set PATH| findstr /C:"%BINDIR%" >NUL

@if %ERRORLEVEL% NEQ 0 @goto addbin
@goto gotbin

:addbin
:: Check for ; at the end of the PATH
@set PATHBINDIR=%BINDIR%
@set PATH| findstr /E /C:";" >NUL
@if %ERRORLEVEL% EQU 1 @set PATHBINDIR=;%PATHBINDIR%
@echo Adding %BINDIR% to PATH... >&2
@echo We used to edit the path using setx but that now truncates to 1024 characters which isn't a lot. >&2
@echo Instead edit the Environment Variables directly for %USER% by running: >&2
@echo rundll32 sysdm.cpl,EditEnvironmentVariables >&2
@echo and set the PATH to: >&2
@echo %PATH%%PATHBINDIR%
::setx PATH "%PATH%%PATHBINDIR%"
set PATH=%PATH%%PATHBINDIR%

:gotbin
@if exist %USERPROFILE%\.cargo @goto rustinstalled

@if exist "%BINDIR%\rustup-init.exe" @goto gotrustupinit

:: Download the rust installer
powershell -Command "Invoke-WebRequest https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe -OutFile %BINDIR%\rustup-init.exe"

:gotrustupinit
"%BINDIR%\rustup-init.exe" -y --no-modify-path

:rustinstalled

:setupregistry
@call %SCRIPT_DIR%setup_registry.bat

:: Install Visual Studio
@call %SCRIPT_DIR%\vs2022\install.bat

:: Bit of a hack for fnm
:: It has all kinds of trickery for manipulating the PATH, and there
:: are things you can do for a Powershell profile, but for cmd there is not
:: a lot. Rather than invoke "fnm env" to generate a bunch of variables
:: in a registry autorun setting,
:: we cheat and just put the "default" alias location on the end of the PATH directly.
:: Totally unsupported...
@set FNM_ME_DIR=%APPDATA%\fnm\aliases\default

:: Check for FNM_ME_DIR in PATH
set PATH| findstr /C:"%FNM_ME_DIR%" >NUL

if %ERRORLEVEL% NEQ 0 @goto addfnm
@goto gotfnm

:addfnm
:: Check for ; at the end of the PATH
@set PATH_FNM_ME_DIR=%FNM_ME_DIR%
@set PATH| findstr /E /C:";" >NUL
@if %ERRORLEVEL% EQU 1 @set PATH_FNM_ME_DIR=;%PATH_FNM_ME_DIR%
@echo Adding fnm default node alias to path...>&2
@echo We used to edit the path using setx but that now truncates to 1024 characters which isn't a lot. >&2
@echo Instead edit the Environment Variables directly for %USER% by running: >&2
@echo rundll32 sysdm.cpl,EditEnvironmentVariables >&2
@echo and set the PATH to: >&2
@echo %PATH%%PATH_FNM_ME_DIR%
::setx PATH "%PATH%%PATH_FNM_ME_DIR%"
set PATH=%PATH%%PATH_FNM_ME_DIR%

:gotfnm
:: Configure vim on windows
:: Switch USERPROFILE from windows to Unix path, search for entry in global gitconfig file on windows.
:: If entry not found, use git to add it.
@echo Addubg safe directory for vim plugins to git config >&2
@findstr /C:"directory = %USERPROFILE:\=/%/.vim/plugged/*" <%USERPROFILE%\.gitconfig >NUL
@if %ERRORLEVEL% EQU 0 @goto :got_git_safedir
:not_got_git_safedir
git config --global --add safe.directory=C:/Users/thatm/.vim/plugged/*
::[safe]
::	directory = %USERPROFILE%/.vim/plugged/*
@goto :extras

:got_git_safedir
@goto :extras

:extras
@echo OPTIONAL: To avoid those annoying zone identifier files you get when you expand zip files for example, >&2
@echo run gpedit.msc and edit >&2
@echo Local Computer Policy/User Configuration/Administrative Templates/Windows Components/Attachment Manager/Do not preserve zone information in file attachments >&2

:exit
