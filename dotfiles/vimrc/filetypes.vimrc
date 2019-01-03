" filetype plugin on
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


