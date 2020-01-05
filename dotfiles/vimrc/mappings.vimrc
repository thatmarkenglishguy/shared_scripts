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

" mE YouCompleteMe
" IntelliJ uses Command+B and Alt+Command+B.
" Let's do the same, and also leader...
:nnoremap <leader>b :YcmCompleter GoToDeclaration<cr>
" This doesn't seem to work on Mac for mapping Alt
:nnoremap <leader><A-b> :YcmCompleter GoToDefinition<cr>
:nnoremap <leader>∫ :YcmCompleter GoToDefinition<cr>
:nnoremap <leader>v :YcmCompleter GoToDefinition<cr>
:nnoremap <leader>f :YcmCompleter FixIt<cr>
:nnoremap <leader>i :YcmCompleter GoToInclude<cr>
:nnoremap <F2> :YcmCompleter RefactorRename<Space>
" This seems to get Alt-Enter working on Mac
set <a-cr>=
:nnoremap <a-cr> :YcmCompleter FixIt<cr>

:command! -nargs=* RunCurrentWithPreviousVarArgs call ClearScreenRunExternalCommandWithPreviousVarArgs(expand('%:p'), <f-args>)
:command! -nargs=* RunCurrentClearPreviousVarArgs call ClearPreviousClearScreenRunExternalCommandWithVarArgs(expand('%:p'), <f-args>)
:nnoremap <C-F5> :RunCurrentWithPreviousVarArgs<cr>
:nnoremap <C-F5><Space> :RunCurrentClearPreviousVarArgs<Space>

" :command! Yay  echom 'Yay ' . <f-args>
" :command! -nargs=* Yay call RunCommandWithPreviousArgs('!' . expand('%:p'), <f-args>)


"nnoremap <C-X> :echom "hi"<cr>

" Identify the syntax highlighting group used at the cursor
" http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
map <F10> :echo "hi<"
\ . synIDattr(synID(line("."),col("."),1),"name")
\ .' (' . synIDattr(synIDtrans(synID(line("."), col("."), 1)), "fg") . ')'
\ . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name")
\ . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
\. ">"<CR>

