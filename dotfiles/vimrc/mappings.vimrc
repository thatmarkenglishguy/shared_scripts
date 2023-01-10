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

if g:use_ycm != 0
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
endif " g:use_ycm

" Note, C-k in Insert mode will let you see the key code.
set <S-F6>=[1;2Q
" On Mac, open Keyboard/Shortcuts/Keyboard and turn off all the F key
" shortcuts, *especially* F8, and F5

" mE CoC/ccls/Clang
" (see https://chmanie.com/post/2020/07/17/modern-c-development-in-neovim/)
if g:use_coc != 0
  " Settings for CoC taken from https://medium.com/geekculture/configuring-neovim-for-c-development-in-2021-33f86296a8b3
  " " if hidden is not set, TextEdit might fail.
  " set hidden
  " " Some servers have issues with backup files, see #649
  " set nobackup
  " set nowritebackup
  " " Better display for messages
  " set cmdheight=2
  " " You will have bad experience for diagnostic messages when it's default 4000.
  " set updatetime=300
  " " don't give |ins-completion-menu| messages.
  " set shortmess+=c
  " " always show signcolumns
  " set signcolumn=yes
  " Use tab for trigger completion with characters ahead and navigate.
  " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction
  " TODO Remove these once a better alternative is found.
  " See https://www.reddit.com/r/neovim/comments/weydql/comment/iiwoxae/
  " inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
  " inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
  " inoremap <silent><expr> <TAB>
  "       \ pumvisible() ? "\<C-n>" :
  "       \ <SID>check_back_space() ? "\<TAB>" :
  "       \ coc#refresh()
  " Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
  " Warning: For some reason this disables the standard <C-i> shortcut 
  " (at least on Mac)
  " nmap <silent> <TAB> <Plug>(coc-range-select)
  " Warning: Ends
  " TODO Ends section to remove

  " remap for complete to use tab and <cr>
  inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ? coc#pum#next(1):
    \ <SID>check_back_space() ? "\<Tab>" :
    \ coc#refresh()
  " Use <c-space> to trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()
  " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
  " Coc only does snippet and additional edit on confirm.
  inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"
  inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
  " Use `[c` and `]c` to navigate diagnostics
  nmap <silent> [c <Plug>(coc-diagnostic-prev)
  nmap <silent> ]c <Plug>(coc-diagnostic-next)
  " Remap keys for gotos
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  " Use K to show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>
  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction
  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')
  " Remap for rename current word
"  nmap <leader>rn <Plug>(coc-rename)
  nmap <S-F6> <Plug>(coc-rename)
  " Remap for format selected region
  xmap <leader>f  <Plug>(coc-format-selected)
  nmap <leader>f  <Plug>(coc-format-selected)
  augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end
  " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
  xmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)
  " Remap for do codeAction of where cursor is
  nmap <leader>ac  <Plug>(coc-codeaction-cursor)
  " Fix autofix problem of current line
  nmap <leader>qf  <Plug>(coc-fix-current)

  xmap <silent> <TAB> <Plug>(coc-range-select)
  xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)
  " Use `:Format` to format current buffer
  command! -nargs=0 Format :call CocAction('format')
  " Use `:Fold` to fold current buffer
  command! -nargs=? Fold :call     CocAction('fold', <f-args>)
  " use `:OR` for organize import of current buffer
  command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
  " Add status line support, for integration with other plugin, checkout `:h coc-status`
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
  " Using CocList
  " Show all diagnostics
  nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
  " Manage extensions
  nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
  " Show commands
  nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
  " Find symbol of current document
  nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
  " Search workspace symbols
  nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
  " Do default action for next item.
  nnoremap <silent> <space>j  :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
  " Resume latest coc list
  nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

"  :nnoremap <leader>f :<c-u>ClangFormat<cr>
endif "g:use_coc

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
" if g:use_ycm != 0
" :nnoremap <a-cr> :YcmCompleter FixIt<cr>
" endif

:command! -nargs=* RunCurrentWithPreviousVarArgs call ClearScreenRunExternalCommandWithPreviousVarArgs(expand('%:p'), <f-args>)
:command! -nargs=* RunCurrentClearPreviousVarArgs call ClearPreviousClearScreenRunExternalCommandWithVarArgs(expand('%:p'), <f-args>)
:nnoremap <C-F5> :RunCurrentWithPreviousVarArgs<cr>
:nnoremap <C-F5><Space> :RunCurrentClearPreviousVarArgs<Space>
:nnoremap <leader>r :RunCurrentWithPreviousVarArgs<cr>
:nnoremap <leader>r<Space> :RunCurrentClearPreviousVarArgs<Space>

" Testing
:nnoremap <silent> <leader>t :TestNearest<cr>
:nnoremap <silent> <leader>T :TestFile<cr>
:nnoremap <silent> <leader>ta :TestSuite<cr>
:nnoremap <silent> <leader>tl :TestLast<cr>
:nnoremap <silent> <leader>tg :TestVisit<cr>

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
