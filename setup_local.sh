#!/usr/bin/env bash

os_name='unknown'
case $(uname -a | tr '[:upper:]' '[:lower:]') in
  *mingw64*)
    os_name='msys'
    ;;
  *cygwin*)
    os_name='cygwin'
    ;;
  *darwin*)
    os_name='darwin'
    ;;
esac

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]
then
  _got_readlink=1
fi

_do_readlink() {
  case "{os_name}" in
    darwin)
      readlink "${1}"
      ;;
    *)
      readlink -f "${1}"
      ;;
  esac
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

