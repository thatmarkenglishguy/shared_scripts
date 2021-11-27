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

:: Now search in the current working directory
@for %%e in (*.exe) do @(
  @set EXE=%%e
  @goto launch
)


:unfound
@echo Unable to find layout installer in current directory or %VS_DOWNLOAD_DIR% >&2
@goto end

:launch
@if not exist %VS_LAYOUT_DIR% mkdir %VS_LAYOUT_DIR%
%EXE% --layout %VS_LAYOUT_DIR% --lang en-US ^
--add Microsoft.VisualStudio.Workload.NativeDesktop ^
--add Microsoft.VisualStudio.Workload.ManagedDesktop ^
--add Microsoft.VisualStudio.Workload.NetWeb ^
--includeRecommended

:end
