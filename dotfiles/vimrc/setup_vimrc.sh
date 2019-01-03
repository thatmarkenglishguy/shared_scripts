#!/usr/bin/env bash
on_mac=0
os_name=$(uname -s)
if [ "${os_name}" == 'Darwin' ]
then
  on_mac=1
fi

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]
then
  _got_readlink=1
fi

_do_readlink() {
  if [ ${on_mac} -eq 1 ]
  then
    readlink "${1}"
  else
    readlink -f "${1}"
  fi
}

if [ ${_got_readlink} -eq 1 ] && [ -z ${BASH_SOURCE} ]
then
  script_dir=$(_do_readlink $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

#set -x
script_vimrcpath="${script_dir}"/root.vimrc
home_vimrcpath=~/.vimrc
actual_home_vimrcpath=$home_vimrcpath
backup_home_vimrcpath=${home_vimrcpath}.old

if [ ${_got_readlink} -eq 1 ]
then
  actual_home_vimrcpath=$(_do_readlink "${actual_home_vimrcpath}")
fi

_pluginUp() {
  if [ ! -e ~/.vim/autoload/plug.vim ]
  then
    echo 'Installing Plugin - https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    # Get the plugin
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  echo 'Installing Vim plugins'
  cat <<EOF >"${script_dir}"/vimrctemp
set nocompatible              " be iMproved, required
filetype off                  " required

" set rtp+=~/.vim/autoload/plug.vim
call plug#begin('~/.vim/plugged')
EOF
  grep "Plug '" "${script_dir}/plugins.vimrc" >> "${script_dir}"/vimrctemp
  if [ -f "${backup_home_vimrcpath}" ]
  then
    grep "Plug '" "${backup_home_vimrcpath}" >> "${script_dir}"/vimrctemp
  fi
  echo 'call plug#end()
' >> "${script_dir}"/vimrctemp

  vim +PlugUpdate +qall -u "${script_dir}"/vimrctemp

  rm "${script_dir}"/vimrctemp
}

if [ ! "${actual_home_vimrcpath}" -ef "${script_vimrcpath}" ]
then
  source_line="source ${script_vimrcpath}"
  read -r -d '' source_lines <<EOF
${source_line}
EOF
  if [ ! -f "${home_vimrcpath}" -o \( -L "${home_vimrcpath}" -a ! -f "${actual_home_vimrcpath}" \) ]
  then
    _pluginUp
    echo 'Creating new '"${home_vimrcpath}"' file.'
    rm "${home_vimrcpath}" 2>/dev/null
    echo "${source_lines}" >"${home_vimrcpath}"
  else
    diff -q "${home_vimrcpath}" "${script_vimrcpath}" >/dev/null
    files_differ=$?
    if [ ${files_differ} -ne 0 ]
    then
      grep "${source_line}" "${home_vimrcpath}" >/dev/null
      if [ $? -ne 0 ]
      then
        if [ ! -f "${backup_home_vimrcpath}" ]
        then
          echo 'Backing up .vimrc'
          cp "${home_vimrcpath}" "${backup_home_vimrcpath}"
        fi

        _pluginUp
        echo 'Updating .vimrc'
        echo "${source_lines}" | cat - "${backup_home_vimrcpath}" > "${actual_home_vimrcpath}"
      else
        echo 'Your .vimrc appears to source the repository .vimrc file already.'
        echo 'Installing plugins...'
        _pluginUp
      fi
    else
      echo 'Your .vimrc file is identical to the one in this git repository.'
      echo 'Replacing it with one that sources this git repository.'
      rm "${home_vimrcpath}"
      echo "${source_lines}" >"${home_vimrcpath}"
    fi
  fi
else
  echo '.vimrc already pointing at this git repository.'
fi

