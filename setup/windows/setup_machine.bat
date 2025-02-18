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
setx PATH "%PATH%%PATHBATSDIR%"
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
setx PATH "%PATH%%PATHBINDIR%"
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


:extras
@echo OPTIONAL: To avoid those annoying zone identifier files you get when you expand zip files for example, >&2
@echo run gpedit.msc and edit >&2
@echo Local Computer Policy/User Configuration/Administrative Templates/Windows Components/Attachment Manager/Do not preserve zone information in file attachments >&2

:exit
