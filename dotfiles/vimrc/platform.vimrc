let g:platform="Unknown"
let g:sub_platform="Unknown"

let uname_result=tolower(system('uname -a'))

if stridx(uname_result, "darwin") != -1
  let g:platform="darwin"
  let g:sub_platform="darwin"
elseif stridx(uname_result, "linuxkit") != -1
  let g:platform="linux_kit"
  let g:sub_platform="linux_kit"
elseif stridx(uname_result, "cygwin") != -1
  let g:platform="cygwin"
elseif stridx(uname_result, "msys") != -1
  let g:platform="msys"
  if stridx(uname_result, "mingw") != -1
    let g:sub_platform="mingw"
  else
    let g:sub_platform="msys"
  endif
elseif stridx(uname_result, "mingw") != -1
  let g:platform="mingw"
endif

:unlet uname_result

