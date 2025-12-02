@set OLD_RUST_PATH=%PATH%
@set RUST_PATH=%USERPROFILE%\.cargo\bin

:: For some reason the . in .cargo needs to be escaped
@set PATH| findstr /C:"%RUST_PATH:.=\.%" >NUL
@if %ERRORLEVEL% NEQ 0 @set PATH=%PATH%;%RUST_PATH%
