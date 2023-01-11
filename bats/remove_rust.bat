@set RUST_PATH=%USERPROFILE%\.cargo\bin

@set PATH| findstr /C:"%RUST_PATH%"
@if %ERRORLEVEL% NEQ 0 @goto got_rust

:got_rust
@if defined OLD_RUST_PATH @set PATH=%OLD_RUST_PATH%
@set OLD_RUST_PATH=

:exit
