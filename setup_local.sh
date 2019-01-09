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
if [ -f "${script_dir}/dotfiles/setup_local_bashrc.sh" ]
then
  echo 'Setting up bashrc.' >&2
  "${script_dir}/dotfiles/setup_local_bashrc.sh"
  echo >&2
  echo
fi

if [ -f "${script_dir}/dotfiles/vimrc/setup_vimrc.sh" ]
then
  echo 'Setting up vimrc.' >&2
  "${script_dir}/dotfiles/vimrc/setup_vimrc.sh"
  echo >&2
fi

