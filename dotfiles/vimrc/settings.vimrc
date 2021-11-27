" Settings made once, and used everywhere

if !exists("g:use_ycm")
  if g:platform != "cygwin" && g:platform != "msys"
      \ && g:platform != "darwin"
    let g:use_ycm=1
    let g:use_coc=0
  else
    let g:use_ycm=0
    let g:use_coc=1
  endif
endif

