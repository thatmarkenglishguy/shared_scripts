" Enable 256 colors in vim
set t_Co=256
" syntax enable
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
colorscheme solarized

let g:lightline = { 'colorscheme': 'solarized'}

"Try to make diff colours a bit more visible.
" Set high visibility for diff mode
let g:solarized_diffmode="high"

set statusline+=%#warningmsg#
set statusline+=%*


