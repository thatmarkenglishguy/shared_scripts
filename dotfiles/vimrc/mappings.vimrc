" Enable backspace deleting
set backspace=indent,eol,start

" Expand %% to current directory
cabbr <expr> %% expand('%:p:h')

" Suggestions from http://learnvimscriptthehardway.stevelosh.com/chapters/07.html

" http://learnvimscriptthehardway.stevelosh.com/chapters/07.html
" Edit the .vimrc file
:nnoremap <leader>ev :vsplit $MYVIMRC<cr>
" Source the .vimrc file
:nnoremap <leader>sv :source $MYVIMRC<cr>

" mE
" Toggling list (whitespace visible)
:nnoremap <leader>wv :set list!<cr>

" Identify the syntax highlighting group used at the cursor
" http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


