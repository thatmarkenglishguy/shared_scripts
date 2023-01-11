:: Install the VisualStudio 2022 layout from the downloaded installer.
:: We expect it to be in C:\stuff\downloads\Apps\Microsoft\VisualStudio\VS2022

@set VS_DOWNLOAD_DIR=C:\stuff\downloads\Apps\Microsoft\VisualStudio\VS2022
@set VS_LAYOUT_DIR=c:\vslayout
@set EXE=

:: Look in the standard download directory
@for %%e in (%VS_DOWNLOAD_DIR%\*.exe) do @(
  @set EXE=%%e
  @goto launch
)

:: Now search the default downloads directory
@set VS_DOWNLOAD_DIR=%USERPROFILE%\Downloads\Apps\Microsoft\VisualStudio\VS2022
@for %%e in (%VS_DOWNLOAD_DIR%\*.exe) do @(
  @set EXE=%%e
  @goto launch
)


:: Now search in the current working directory
@for %%e in (*.exe) do @(
  @set EXE=%%e
  @goto launch
)


:unfound
@set VS_DOWNLOAD_DIR=%USERPROFILE%\Downloads\Apps\Microsoft\VisualStudio\VS2022
@set VS_DOWNLOAD_PATH=%VS_DOWNLOAD_DIR%\vs_Community.exe
if not exist %VS_DOWNLOAD_DIR% mkdir %VS_DOWNLOAD_DIR%
powershell -Command "Invoke-WebRequest https://aka.ms/vs/17/release/vs_Community.exe -OutFile %VS_DOWNLOAD_PATH%"
@if exist %VS_DOWNLOAD_PATH% @(
  @set EXE=%VS_DOWNLOAD_PATH%
  @goto launch
)
@echo Unable to find layout installer in current directory or %VS_DOWNLOAD_DIR% >&2
@goto end

:launch
@if not exist %VS_LAYOUT_DIR% mkdir %VS_LAYOUT_DIR%

:: Microsoft.VisualStudio.Component.VC.ATLMFC

%EXE% --layout %VS_LAYOUT_DIR% --lang en-US ^
--passive ^
--add Microsoft.VisualStudio.Workload.NativeDesktop ^
--add Microsoft.VisualStudio.Workload.ManagedDesktop ^
--add Microsoft.VisualStudio.Workload.NetWeb ^
--add Microsoft.VisualStudio.Component.VC.ATLMFC ^
--includeRecommended

:end
