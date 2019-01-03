" source /home/mark/code/shscripts/cloudhousetech/vimrc.git/.vimrc
" source /home/marke/code/shscripts/thirdparty/cloudhousetech/vimrc.git/.vimrc
" source /c/code/onpath/dotfiles/.vimrc

syntax on

" Make iTerm2 happy
" set term=xterm-256color

" Note: syntax enable resets the syntax
" filetype plugin indent on
" syntax enable
" Italic/bold look like white background on Mac iterm2 :(

hi Comment ctermfg=DarkGreen guifg=Green
hi Number ctermfg=Yellow
hi String ctermfg=DarkRed guifg=Red
hi Function ctermfg=LightGrey
" hi Identifier ctermfg=White cterm=italic
hi Identifier ctermfg=White
hi Macro ctermfg=Cyan 
hi Statement ctermfg=Grey
hi Define ctermfg=Red 
hi Normal ctermfg=LightGrey
hi Special ctermfg=Grey
hi PreProc ctermfg=LightBlue
hi Conditional ctermfg=LightGrey
hi Repeat ctermfg=LightGrey
hi Label ctermfg=LightGrey
hi Operator ctermfg=LightGrey
hi Keyword ctermfg=Red
hi Exception ctermfg=LightGrey
hi NonText ctermfg=DarkGrey ctermbg=NONE
hi SpecialKey ctermfg=DarkGrey ctermbg=NONE
set listchars=eol:¶,tab:»·,trail:~,extends:>,precedes:<,space:·
set list
hi vimHiCtermError ctermfg=DarkRed ctermbg=NONE cterm=underline guifg=Red guibg=NONE gui=underline
hi vimCommand guifg=DarkYellow guibg=NONE gui=bold
"hi vimCommand ctermfg=Brown ctermbg=NONE cterm=bold guifg=DarkYellow guibg=NONE gui=bold
hi vimVar guifg=LightGrey gui=bold
hi vimOper guifg=LightGrey gui=bold
hi vimIsCommand guifg=LightGrey
hi vimUserFunc ctermfg=LightGrey guifg=LightGrey
hi vimAutoCmdSfxList ctermfg=LightGrey guifg=LightGrey
hi vimLineComment ctermfg=DarkGreen guifg=Green
hi vimSetEqual ctermfg=Yellow guifg=Yellow
hi vimSet ctermfg=Yellow guifg=Yellow
hi vimOption ctermfg=Cyan guifg=Cyan
hi vimMapRhs ctermfg=LightGrey guifg=LightGrey
hi vimMapRhsExtend ctermfg=LightGrey guifg=LightGrey
hi vimFuncName ctermfg=LightGrey guifg=LightGrey
"hi vimHiCtermFgBf ctermfg=
hi vimHiCtermColor ctermfg=Yellow
hi vimNotation ctermfg=Cyan cterm=italic guifg=Cyan gui=italic
hi vimBracket ctermfg=LightYellow guifg=LightYellow

" show existing tab with 2 spaces width
set tabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
" On pressing tab, insert 2 spaces
set expandtab
" source .vimrc file if it's present in working directory
set exrc
" This is for setting Makefiles with tabs not spaces
autocmd FileType make setlocal noexpandtab

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
:set list


