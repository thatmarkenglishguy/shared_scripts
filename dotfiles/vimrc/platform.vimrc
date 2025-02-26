let g:platform="Unknown"
let g:sub_platform="Unknown"

if has('win32')
  let g:platform="windows"
  let g:sub_platform="win32"
elseif has('win64')
  let g:platform="windows"
  let g:sub_platform="win64"
else

  let uname_result=tolower(system('uname -a'))

  if stridx(uname_result, "darwin") != -1
    let g:platform="darwin"
    let g:sub_platform="darwin"
  elseif stridx(uname_result, "linuxkit") != -1
    let g:platform="linux_kit"
    let g:sub_platform="linux_kit"
  elseif stridx(uname_result, "wsl") != -1
    let lsb_release_result=tolower(system("lsb_release -d"))
    if stridx(lsb_release_result, "ubuntu") != -1
      let g:platform="ubuntu"
      let g:sub_platform="ubuntu"
    endif
    unlet lsb_release_result
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
endif
