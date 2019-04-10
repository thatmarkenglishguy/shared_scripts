" filetype plugin on
filetype on
filetype plugin indent on

" Read Vagrantfile as a ruby file
" https://github.com/hashicorp/vagrant/blob/master/contrib/vim/vagrantfile.vim
augroup vagrant
  au!
  au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END

" Antlr plugin fork for Antlr4 support
Plug 'dylon/vim-antlr'
au BufRead,BufNewFile *.g set filetype=antlr3
au BufRead,BufNewFile *.g4 set filetype=antlr4

augroup elixir
  autocmd!
  autocmd FileType elixir noremap <F5> :!clear & mix test<CR>
  autocmd FileType elixir noremap <F6> :!clear & elixir %<CR>
augroup END


augroup python
  autocmd!
  autocmd FileType python noremap <F5> :!clear & python3 %<cr>
augroup END

augroup java
  autocmd!
  autocmd FileType java noremap <F5> :!clear & gradle test %<cr>
augroup END

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

