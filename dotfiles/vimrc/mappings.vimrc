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

" mE
" Show hex
:nnoremap <leader>x :call ToggleHex()<cr>

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
" Note, C-k in Insert mode will let you see the key code.
set <S-F6>=[1;2Q
" On Mac, open Keyboard/Shortcuts/Keyboard and turn off all the F key
" shortcuts, *especially* F8, and F5

" F8 because that's what VSCode uses on Windows and Linux and the Mac mappings
" are too difficult to emulate.
nnoremap <C-F8> :call ToggleLocationList()<cr>
nnoremap <F8> :lne<cr>
nnoremap <S-F8> :lN<cr>
" In VSCode show problems is Shift-Cmd-M
"
" This seems to get Alt-Enter working on Mac
"  However, subsequently changing left-Alt in Iterm2 disables Alt in general, and totally breaks the
"  escape key, so we've turned it off.
" set <a-cr>=
" :nnoremap <a-cr> :YcmCompleter FixIt<cr>

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
