" filetype plugin on
filetype on
filetype plugin indent on

" Read Vagrantfile as a ruby file
" https://github.com/hashicorp/vagrant/blob/master/contrib/vim/vagrantfile.vim
augroup vagrant
  autocmd!
  autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END

" Edit .rc file as shell file
augroup rc_file
  autocmd!
  autocmd BufRead,BufNewFile *.rc set filetype=sh
  autocmd BufRead,BufNewFile *.bashrc set filetype=sh
augroup END

" Antlr plugin fork for Antlr4 support
Plug 'dylon/vim-antlr'
autocmd BufRead,BufNewFile *.g set filetype=antlr3
autocmd BufRead,BufNewFile *.g4 set filetype=antlr4

" Elixir
augroup elixir
  autocmd!
  autocmd FileType elixir noremap <F5> :!clear & mix test<CR>
  autocmd FileType elixir noremap <F6> :!clear & elixir %<CR>
augroup END

" Gradle/Kotlin
augroup Kotlin
  autocmd!
  autocmd BufRead,BufNewFile *.kts set filetype=Kotlin
augroup END

" Jenkinsfile
augroup Jenkinsfile
  autocmd!
  autocmd BufRead,BufNewFile Jenkinsfile set filetype=Groovy
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

" Rust commands used in rust and toml
" Not sure but looks like it has to be execute + string using a:filetype, as
" a:filetypes doesn't get expanded automatically...
:function! DefineRustCommands(filetype)
  " This overrides the YouCompleteMe defaults in mappings.vimrc which are
  " based on IntelliJ.
  " These mappings are mostly based on Visual Studio Code (increasingly
  " prefering Windows/Linux layout over Mac)..
  " On Mac, Ctrl+Function key not supported in iterm2 by default in older
  " versions.
  " Preferences -> <Your Profile> -> Keys -> Presets click 'xterm Defaults'
  " https://apple.stackexchange.com/questions/281033/sending-ctrlfunction-key-on-iterm2
  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoRunWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs(''cargo run'', <f-args>)'
  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoRunClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs(''cargo run'', <f-args>)'
  execute 'autocmd FileType ' . a:filetype . ' noremap <C-F5> :CargoRunWithPreviousArgs<cr>'
  execute 'autocmd FileType ' . a:filetype . ' noremap <C-F5><Space> :CargoRunClearPreviousArgs<Space>'
  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>r :CargoRunWithPreviousArgs<cr>'
  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>r<Space> :CargoRunClearPreviousArgs<Space>'
'
  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoCheckWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs(''cargo check'', <f-args>)'
  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoCheckClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs(''cargo check'', <f-args>)'
  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>b :CargoCheckWithPreviousArgs<cr>'
  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>b<Space> :CargoCheckClearPreviousArgs<Space>'
'
  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoFormatWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs(''cargo fmt'', <f-args>)'
  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoFormatClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs(''cargo fmt'', <f-args>)'
  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>f :CargoFormatWithPreviousArgs<cr>'
  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>f<Space> :CargoFormatClearPreviousArgs<Space>'
'
"  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoTestWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs(''cargo test'', <f-args>)'
"  execute 'autocmd FileType ' . a:filetype . ' command! -nargs=* CargoTestClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs(''cargo test'', <f-args>)'
"  execute 'autocmd FileType ' . a:filetype . ' noremap <leader>t :CargoTestWithPreviousArgs<cr>'
"  execute 'autocmd FileType a:filetype noremap <leader>t<Space> :CargoTestClearPreviousArgs<Space>'

  if g:use_coc == 0
    if g:use_ycm != 0
      autocmd FileType a:filetype noremap <F12> :YcmCompleter GoToDefinition<cr>
    endif
  endif
:endfunction

" toml
augroup toml
  autocmd!
  call DefineRustCommands('toml')
augroup END

" rust
augroup rust
  autocmd!
  call DefineRustCommands('rust')
"  " This overrides the YouCompleteMe defaults in mappings.vimrc which are
"  " based on IntelliJ.
"  " These mappings are mostly based on Visual Studio Code (increasingly
"  " prefering Windows/Linux layout over Mac)..
"  " On Mac, Ctrl+Function key not supported in iterm2 by default in older
"  " versions.
"  " Preferences -> <Your Profile> -> Keys -> Presets click 'xterm Defaults'
"  " https://apple.stackexchange.com/questions/281033/sending-ctrlfunction-key-on-iterm2
"  autocmd FileType rust command! -nargs=* CargoRunWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo run', <f-args>)
"  autocmd FileType rust command! -nargs=* CargoRunClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo run', <f-args>)
"  autocmd FileType rust noremap <C-F5> :CargoRunWithPreviousArgs<cr>
"  autocmd FileType rust noremap <C-F5><Space> :CargoRunClearPreviousArgs<Space>
"  autocmd FileType rust noremap <leader>r :CargoRunWithPreviousArgs<cr>
"  autocmd FileType rust noremap <leader>r<Space> :CargoRunClearPreviousArgs<Space>
"
"  autocmd FileType rust command! -nargs=* CargoCheckWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo check', <f-args>)
"  autocmd FileType rust command! -nargs=* CargoCheckClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo check', <f-args>)
"  autocmd FileType rust noremap <leader>b :CargoCheckWithPreviousArgs<cr>
"  autocmd FileType rust noremap <leader>b<Space> :CargoCheckClearPreviousArgs<Space>
"
"  autocmd FileType rust command! -nargs=* CargoFormatWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo fmt', <f-args>)
"  autocmd FileType rust command! -nargs=* CargoFormatClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo fmt', <f-args>)
"  autocmd FileType rust noremap <leader>f :CargoFormatWithPreviousArgs<cr>
"  autocmd FileType rust noremap <leader>f<Space> :CargoFormatClearPreviousArgs<Space>
"
"  autocmd FileType rust command! -nargs=* CargoTestWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('cargo test', <f-args>)
"  autocmd FileType rust command! -nargs=* CargoTestClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('cargo test', <f-args>)
"  autocmd FileType rust noremap <leader>t :CargoTestWithPreviousArgs<cr>
"  autocmd FileType rust noremap <leader>t<Space> :CargoTestClearPreviousArgs<Space>
"
"  if g:use_coc == 0
"    if g:use_ycm != 0
"      autocmd FileType rust noremap <F12> :YcmCompleter GoToDefinition<cr>
"    endif
"  endif
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

" Terraform
augroup tf
  autocmd!
  " Plan
  autocmd FileType tf command! -nargs=* TerraformPlanWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('terraform plan', <f-args>)
  autocmd FileType tf command! -nargs=* TerraformPlanClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('terraform plan', <f-args>)
  autocmd FileType tf noremap <leader>p :TerraformPlanWithPreviousArgs<cr>
  autocmd FileType tf noremap <leader>p<Space> :TerraformPlanClearPreviousArgs<Space>

  " Apply
  autocmd FileType tf command! -nargs=* TerraformApplyWithPreviousArgs call ClearScreenRunExternalCommandHereWithPreviousVarArgs('terraform apply', <f-args>)
  autocmd FileType tf command! -nargs=* TerraformApplyClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('terraform apply', <f-args>)
  autocmd FileType tf noremap <leader>a :TerraformApplyWithPreviousArgs<cr>
  autocmd FileType tf noremap <leader>a<Space> :TerraformApplyClearPreviousArgs<Space>

  " Refresh
  autocmd FileType tf command! -nargs=* TerraformRefreshClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('terraform refresh', <f-args>)
  autocmd FileType tf noremap <leader>r :TerraformRefreshClearPreviousArgs<cr>

  " Output
  autocmd FileType tf command! -nargs=* TerraformOutputClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('terraform output', <f-args>)
  autocmd FileType tf noremap <leader>o :TerraformOutputClearPreviousArgs<cr>

  " Taint
  autocmd FileType tf command! -nargs=* TerraformTaintClearPreviousArgs call ClearPreviousClearScreenRunExternalCommandHereWithVarArgs('terraform taint', <f-args>)
  autocmd FileType tf noremap <leader>t<Space> :TerraformTaintClearPreviousArgs<Space>

  " Destroy
  autocmd FileType tf noremap <leader>d !terraform destroy
augroup END

