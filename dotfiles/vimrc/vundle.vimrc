" Standard Vundle setup
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
if g:use_ycm == 1
  Plugin 'Valloric/YouCompleteMe'
endif
call vundle#end()            " required

filetype plugin indent on    " required

if g:platform != "cygwin" && g:platform != "msys"
  " 
  " YouCompleteMe configuration
  " let g:ycm_server_python_interpreter = '/usr/bin/python'
  " let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
  let g:ycm_server_python_interpreter = system('which python3')
  while g:ycm_server_python_interpreter[-1:] != '3'
    let g:ycm_server_python_interpreter = g:ycm_server_python_interpreter[:-2]
  endwhile

  " Rust seems to require this.
  " https://github.com/ycm-core/YouCompleteMe#the-gycm_disable_signature_help-option
  let g:ycm_disable_signature_help = 1

  " let g:ycm_clangd_binary_path='clangd'
else
  let g:ycm_server_python_interpreter = system("cygpath \"$(py -c \"import sys; print(sys.executable)\")\" | tr -d '\n'")
"  echo "ycm python interpreter is: ".g:ycm_server_python_interpreter
"  let g:ycm_server_python_interpreter = system('which python3')
  while g:ycm_server_python_interpreter[-1:] != '3'
    let g:ycm_server_python_interpreter = g:ycm_server_python_interpreter[:-2]
  endwhile

  " Rust seems to require this.
  " https://github.com/ycm-core/YouCompleteMe#the-gycm_disable_signature_help-option
  let g:ycm_disable_signature_help = 1
endif
