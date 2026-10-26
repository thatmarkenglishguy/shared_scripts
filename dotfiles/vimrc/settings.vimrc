" Settings made once, and used everywhere

" Define platforms that support/prefer CoC
let s:coc_platforms = [
    \ 'windows',
    \ 'cygwin',
    \ 'msys',
    \ 'darwin',
    \ 'linux_kit',
    \ 'ubuntu',
    \ 'penguin',
    \ ]

" 1. Configure YCM
if !exists("g:use_ycm")
  if index(s:coc_platforms, g:platform) != -1
    let g:use_ycm = 0
  else
    let g:use_ycm = 1
  endif
endif

" 2. Configure CoC (Runs if g:use_coc doesn't exist OR if g:use_ycm is 0)
if !exists("g:use_coc") || g:use_ycm == 0
  if index(s:coc_platforms, g:platform) != -1
    let g:use_coc = 1
  else
    let g:use_coc = 0
  endif
endif

