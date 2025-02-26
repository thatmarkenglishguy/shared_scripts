:: Plugin managers for vim.
@setlocal
@set SCRIPT_DIR=%~dp0
@set _VIMROOT=%USERPROFILE%\vimfiles
@set _VIMRCPLUGPATH=%SCRIPT_DIR%vimrctemp_vimplug
::@set _DO=@echo
@set _DO=

@echo Downloading plug.vim >&2
%_DO% mkdir %_VIMROOT%\autoload
%_DO% powershell Invoke-WebRequest "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -OutFile %_VIMROOT%\autoload\plug.vim"
@dir %_VIMROOT%\autoload

@echo Creating directory structure >&2
mkdir %_VIMROOT%\bundle 2>NUL
:: Note 'pack' is mandatory. 'plugins' is an optional name I picked after reading
:: https://github.com/udalov/kotlin-vim
mkdir %_VIMROOT%\pack\plugins 2>NUL
mkdir %_VIMROOT%\plugged 2>NUL


@echo Temporary vimrctemp_plug setup file >&2
del %_VIMRCPLUGPATH% 2>NUL

@echo set _VIMRCPLUGPATH=%_VIMRCPLUGPATH% >&2

@echo set nocompatible              ^" be iMproved, required >>%_VIMRCPLUGPATH%
@echo let path = expand('^<sfile^>:h') >>%_VIMRCPLUGPATH%
@echo let g:use_coc = 1 >>%_VIMRCPLUGPATH%
@echo let g:use_ycm = 0 >>%_VIMRCPLUGPATH%
@echo exec 'source' path . '\platform.vimrc' >>%_VIMRCPLUGPATH%
@echo exec 'source' path . '\settings.vimrc' >>%_VIMRCPLUGPATH%
@echo exec 'source' path . '\plugins.vimrc' >>%_VIMRCPLUGPATH%


%_DO% @call vim +qall +PlugUpdate +'CocUpdateSync' -u %_VIMRCPLUGPATH%

%_DO% @echo CoC plugins >&2
%_DO% @call vim +qall +CocInstall coc-pyright -u %_VIMRCPLUGPATH%
%_DO% @call vim +qall +CocInstall sync -coc-json coc-rust-analyzer -u %_VIMRCPLUGPATH%

:: Needs git
:: @echo Kotlin Native Vim plugin >&2


@echo Checking _vimrc exists >&2
%_DO% @if not exist %_VIMROOT%_vimrc @echo source %SCRIPT_DIR%root.vimrc >%_VIMROOT%_vimrc
@set SCRIPT_DIR=
@set _VIMROOT=
@set _VIMRCPLUGPATH=
@set _DO=

@endlocal

