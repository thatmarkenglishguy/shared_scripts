:: Install the layout directory, then install Visual Studio from the layout directory
@set SCRIPT_DIR=%~dp0
@call %SCRIPT_DIR%/install_layout.bat
@call %SCRIPT_DIR%/install_vs_from_layout.bat
