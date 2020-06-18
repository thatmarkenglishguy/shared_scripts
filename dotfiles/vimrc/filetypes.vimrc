" filetype plugin on
filetype on
filetype plugin indent on

" Read Vagrantfile as a ruby file
" https://github.com/hashicorp/vagrant/blob/master/contrib/vim/vagrantfile.vim
augroup vagrant
  au!
  au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END

" Edit .rc file as shell file
augroup rc_file
  autocmd!
  au BufRead,BufNewFile *.rc set filetype=sh
  au BufRead,BufNewFile *.bashrc set filetype=sh
augroup END

" Antlr plugin fork for Antlr4 support
Plug 'dylon/vim-antlr'
au BufRead,BufNewFile *.g set filetype=antlr3
au BufRead,BufNewFile *.g4 set filetype=antlr4

" Elixir
augroup elixir
  autocmd!
  autocmd FileType elixir noremap <F5> :!clear & mix test<CR>
  autocmd FileType elixir noremap <F6> :!clear & elixir %<CR>
augroup END


" Python
augroup python
  autocmd!
  autocmd FileType python noremap <F5> :!clear & python3 %<cr>
augroup END

" Java
augroup java
  autocmd!
  autocmd FileType java noremap <F5> :!clear & gradle test %<cr>
augroup END

" Generic functions
:function! SurroundLineWithDelimiter(delimiter)
:  call setline('.', a:delimiter . getline('.') . a:delimiter)
:endfunction

:function! SurroundWithDelimiter(delimiter)
: let currentcol=col('.') - 1
: if currentcol == 0
:   call SurroundLineWithDelimiter(a:delimiter)
: else
:   let currentline=getline('.')
:   let newline = currentline[0:currentcol-1] . a:delimiter . currentline[currentcol:] . a:delimiter
:   call setline('.', newline)
: endif
:endfunction

" Markdown
augroup markdown
  autocmd!
  " Surround from current location
  autocmd FileType markdown nnoremap <leader>_ :call SurroundWithDelimiter('_')<cr>
  autocmd FileType markdown nnoremap <leader>* :call SurroundWithDelimiter('*')<cr>
  autocmd FileType markdown nnoremap <leader>** :call SurroundWithDelimiter('**')<cr>
  " Double press leader to surround line
  autocmd FileType markdown nnoremap <leader><leader>_ :call SurroundLineWithDelimiter('_')<cr>
  autocmd FileType markdown nnoremap <leader><leader>* :call SurroundLineWithDelimiter('*')<cr>
  autocmd FileType markdown nnoremap <leader><leader>** :call SurroundLineWithDelimiter('**')<cr>
augroup END

"" Example command and mapping
":command! -nargs=* ExecuteEchoPwd call ClearScreenRunExternalCommandHereWithPreviousVarArgs('pwd')
":nnoremap <C-X> :ExecuteEchoPwd<cr>

" Rust
augroup Rust
  autocmd!
  " This overrides the YouCompleteMe defaults in mappings.vimrc which are
  " based on IntelliJ.
  " These mappings are mostly based on Visual Studio Code (increasingly
  " prefering Windows/Linux layout over Mac)..
  " On Mac, Ctrl+Function key not supported in iterm2 by default in older
  " versions.
  " Preferences -> <Your Profile> -> Keys -> Presets click 'xterm Defaults'
  " https://apple.stackexchange.com/questions/281033/sending-ctrlfunction-key-on-iterm2
  autocmd FileType Rust command! -nargs=* CargoRunWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo run', <f-args>)
  autocmd FileType Rust command! -nargs=* CargoRunClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo run', <f-args>)
  autocmd FileType Rust noremap <C-F5> :CargoRunWithPreviousArgs<cr>
  autocmd FileType Rust noremap <C-F5><Space> :CargoRunClearPreviousArgs<Space>

  autocmd FileType Rust command! -nargs=* CargoCheckWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo check', <f-args>)
  autocmd FileType Rust command! -nargs=* CargoCheckClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo check', <f-args>)
  autocmd FileType Rust noremap <leader>b :CargoCheckWithPreviousArgs<cr>
  autocmd FileType Rust noremap <leader>b<Space> :CargoCheckClearPreviousArgs<Space>

  autocmd FileType Rust command! -nargs=* CargoTestWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo test', <f-args>)
  autocmd FileType Rust command! -nargs=* CargoTestClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo test', <f-args>)
  autocmd FileType Rust noremap <leader>t :CargoTestWithPreviousArgs<cr>
  autocmd FileType Rust noremap <leader>t<Space> :CargoTestClearPreviousArgs<Space>

  autocmd FileType Rust noremap <F12> :YcmCompleter GoToDefinition<cr>
augroup END

" Makefile
" This is for setting Makefiles with tabs not spaces
autocmd FileType make setlocal noexpandtab

" C++
augroup cpp
  autocmd FileType cpp command! -nargs=* InsertHeaderGuardBlock call InsertCppHeaderGuardBlockVarArgs(<f-args>)
  autocmd FileType cpp noremap <leader>h :InsertHeaderGuardBlock<cr>
  autocmd FileType cpp noremap <leader>h<Space> :InsertHeaderGuardBlock<Space>
augroup END

