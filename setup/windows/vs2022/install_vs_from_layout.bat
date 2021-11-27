:: Install Visual Studio 2022 from the Layout directory
 
@for %%e in (c:\vslayout\*.exe) do @(
  @set LAYOUT_EXE=%%e
  @goto launch_layout
)

:unfound
@echo Unable to find installer executable in c:\vslayout >&2
@goto end

:launch_layout
%LAYOUT_EXE% ^
--add Microsoft.VisualStudio.Workload.NativeDesktop ^
--add Microsoft.VisualStudio.Workload.ManagedDesktop ^
--add Microsoft.VisualStudio.Workload.NetWeb ^
--includeRecommended
 
:end
