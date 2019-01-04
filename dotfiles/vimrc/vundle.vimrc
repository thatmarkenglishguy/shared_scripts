" Standard Vundle setup
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()            " required
filetype plugin indent on    " required
" 
" YouCompleteMe configuration
" let g:ycm_server_python_interpreter = '/usr/bin/python'
let g:ycm_server_python_interpreter = '/usr/local/bin/python3'

