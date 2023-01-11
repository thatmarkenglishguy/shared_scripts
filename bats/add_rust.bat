@set OLD_RUST_PATH=%PATH%
@set RUST_PATH=%USERPROFILE%\.cargo\bin

@set PATH| findstr /C:"%RUST_PATH%"
@if %ERRORLEVEL% NEQ 0 @set PATH=%PATH%;%RUST_PATH%
