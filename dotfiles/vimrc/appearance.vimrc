" Enable 256 colors in vim
set t_Co=256
" syntax enable
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1

" show existing tab with 2 spaces width
set tabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
" On pressing tab, insert 2 spaces
set expandtab
" source .vimrc file if it's present in working directory
set exrc

" Settings moved from forked vimrc
set softtabstop=2
set autowrite
set incsearch
set nocompatible
set number
set ttyfast
set hlsearch
set laststatus=2
set noshowmode

" set t_Co=256
" syntax enable NOT SURE ABOUT THIS see comment above

" Turn on omni-completion
set omnifunc=syntaxcomplete#Complete

" Make whitespace visible
:set listchars=eol:¶,tab:»·,trail:~,extends:>,precedes:<,space:·
:set nolist
" :set list

colorscheme solarized

let g:lightline = { 'colorscheme': 'solarized'}

"Try to make diff colours a bit more visible.
" Set high visibility for diff mode
let g:solarized_diffmode="high"

set statusline+=%#warningmsg#
set statusline+=%*


