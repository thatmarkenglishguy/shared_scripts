:: Setup all the things

:: You might have to do this line yourself if you've checked out this repo inside WSL
:: You might see a CreateProcessEntryCommon error but can ignore it
@for /f %%u in ('wsl.exe whoami') do @(
  @set WSLUSER=%%u
  @goto founduser
)

echo "No wsl user for you" >&2
@goto exit

:founduser
@echo Found WSLUSER: %WSLUSER%
@if not exist %USERPROFILE%\wslme mklink /D %USERPROFILE%\wslme \\wsl.localhost\Ubuntu\home\%WSLUSER%

:: Import all the standard things, including:
:: * Python3
:: * Notepad++
:: * SysInternals
winget import --accept-source-agreements --accept-package-agreements winget_imports_setup.json

:: Install PyWin32
py -m pip install --upgrade pywin32

:: Sort out a place to put random binaries
@set BINDIR=c:\bin
@if not exist %BINDIR% mkdir %BINDIR%

:: Check for BINDIR in PATH
@set PATH| findstr /C:"%BINDIR%" >NUL

@if %ERRORLEVEL% NEQ 0 @goto addbin
@goto gotbin

:addbin
:: Check for ; at the end of the PATH
@set PATHBINDIR="%BINDIR%"
@set PATH| findstr /E /C:";" >NUL
@if %ERRORLEVEL% EQU 1 @set PATHBINDIR=";%PATHBINDIR%" 
setx PATH "%PATH%%PATHBINDIR%"

:gotbin

@if EXIST "%BINDIR%\rustup-init.exe" @goto gotrustup

:: Download the rust installer
powershell -Command "Invoke-WebRequest https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe -OutFile %BINDIR%\rustup-init.exe"

:gotrustup
"%BINDIR%\rustup-init.exe" -y --no-modify-path


:exit
