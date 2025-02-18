:: Make changes to the registry

@set SETUP_REGISTRY_SCRIPT_DIR=%~dp0

@echo Setting up registry >&2
@echo  Importing registry files >&2
@for %%f in (%SETUP_REGISTRY_SCRIPT_DIR%registry_changes\*.reg) do @reg IMPORT %%f

@echo  Editing registry >&2
@echo  Before change to HKCU\Software\Microsoft\Command Processor >&2
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun

@for %%f in (%SETUP_REGISTRY_SCRIPT_DIR%registry_changes\*.doskey) do @reg add "HKCU\Software\Microsoft\Command Processor" /v Autorun /d "doskey /macrofile=\"%%f\"" /f

@echo  After change to HKCU\Software\Microsoft\Command Processor >&2
reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun

@echo Finished setting up registry >&2

