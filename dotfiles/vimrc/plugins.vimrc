" set rtp+=~/.vim/autoload/plug.vim
call plug#begin('~/.vim/plugged')

Plug 'elixir-lang/vim-elixir'
Plug 'mattreduce/vim-mix'
Plug 'kien/ctrlp.vim'
Plug 'itchyny/lightline.vim'
Plug 'altercation/vim-colors-solarized'
Plug '~/.fzf'
Plug 'dylon/vim-antlr'
Plug 'gyim/vim-boxdraw'
Plug 'mtdl9/vim-log-highlighting' " log syntax highlighting. We shall see (01/10/2022)
Plug 'rust-lang/rust.vim'
" Language servers (notably Rust)
" This looks like one guy having a go
"Plug 'prabirshrestha/async.vim'
"Plug 'prabirshrestha/vim-lsp'

" This looks like the real deal.
" Plug 'autozimu/LanguageClient-neovim', {
"     \ 'branch': 'next',
"     \ 'do': 'bash install.sh',
"     \ }
Plug 'junegunn/fzf.vim'

if g:use_coc != 0
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'jackguo380/vim-lsp-cxx-highlight'
  " Linting for CoC using ALE
  " (see https://chmanie.com/post/2020/07/17/modern-c-development-in-neovim/)
  Plug 'vim-syntastic/syntastic'
  " File formatting
"  Plug 'rhysd/vim-clang-format'
endif
call plug#end()

" For fzf-plugin
" See plugin which ships with fzf instructions at:
" https://github.com/junegunn/fzf#as-vim-plugin
set rtp+=~/.fzf

" if executable('rls')
"     au User lsp_setup call lsp#register_server({
"         \ 'name': 'rls',
"         \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
"         \ 'workspace_config': {'rust': {'clippy_preference': 'on'}},
"         \ 'whitelist': ['rust'],
"         \ })
" endif
set hidden

" if executable('rls')
"   let g:LanguageClient_serverCommands = {
"       \ 'rust': ['rls'],
"       \ }
" else
"   let g:LanguageClient_serverCommands = {
"       \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
"       \ }
" endif


