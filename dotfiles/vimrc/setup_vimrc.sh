#!/usr/bin/env bash

# Where am I ?
platform=unknown

case $(uname -a | tr '[:upper:]' '[:lower:]') in
  *darwin*)
    platform=darwin
    ;;
  *cygwin*)
    platform=cygwin
    ;;
  *msys*|*mingw*)
    platform=msys
    ;;
  *)
    echo 'Unrecognised platform ' >&2
    uname -a
    ;;
esac

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]
then
  _got_readlink=1
fi

_do_readlink() {
  case "${platform}" in
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


# Global variables
Script_vimrcpath="${script_dir}"/root.vimrc
home_vimrcpath=~/.vimrc
actual_home_vimrcpath=$home_vimrcpath
backup_home_vimrcpath=${home_vimrcpath}.old

if [ ${_got_readlink} -eq 1 ]
then
  actual_home_vimrcpath=$(_do_readlink "${actual_home_vimrcpath}")
fi

function _grab_multiline_plug_commands() {
  sed -n "/Plug[[:space:]]*'[^']*'\\,[[:space:]]*{/,/[[:space:]]*}/{
    p
  }" "${1}"
}

function _grab_singleline_plug_commands() {
  sed -n "/.*Plug '[^']*'$/p" "${1}"
}

function _grab_plug_commands() {
  _grab_multiline_plug_commands "${1}"
  _grab_singleline_plug_commands "${1}" 
}

# Internal functions
_pluginUp() {
  local do_vundle
  local do_plug
  local do_quit_vim
  local do_delete_tempfile
  local vim_quit_command

  do_vundle=${1:-1}
  do_plug=${2:-1}
  do_quit_vim=${3:-1}
  do_delete_tempfile=${4:-1}
  vim_quit_command='+qall'

  if [ ${do_quit_vim} -eq 0 ]
  then
    vim_quit_command=''
  fi


  if [ ! -e "${HOME}/.vim/autoload/plug.vim" ]
  then
    echo 'Installing Plugin - https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    # Get the plugin
    curl -fLo "${HOME}/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  if [ ! -d "${HOME}/.vim/bundle/Vundle.vim" ]
  then
    if ! which git 2>&1 1>/dev/null
    then
      echo 'git not installed. Please install git.'
      case "${platform}" in
        darwin)
          brew install git
          ;;
        msys)
          pacman -S git
          ;;
        *)
          echo 'Unknown platform for git installation.'
          exit 1
          ;;
      esac
    fi

    echo 'Cloning Vundle...'
    git clone https://github.com/VundleVim/Vundle.vim.git "${HOME}/.vim/bundle/Vundle.vim"
  fi

  echo 'Installing Vim plugins'

  if [ ${do_vundle} -ne 0 ]
  then
    rm -f "${script_dir}/vimrctemp_vundle"
    cat <<EOF >"${script_dir}/vimrctemp_vundle"
" Vundle
" Standard Vundle setup
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

EOF
    grep "Plugin '" "${script_dir}/vundle.vimrc" >> "${script_dir}"/vimrctemp_vundle
    if [ -f "${backup_home_vimrcpath}" ]
    then
      grep "Plugin '" "${backup_home_vimrcpath}" >> "${script_dir}"/vimrctempvundle
    fi
    cat <<EOF >>"${script_dir}"/vimrctemp_vundle
call vundle#end()            " required
filetype plugin indent on    " required
EOF
  fi

  if [ ${do_plug} -ne 0 ]
  then
    rm -f "${script_dir}/vimrctemp_vimplug"
    cat <<EOF >>"${script_dir}"/vimrctemp_vimplug
" vim-plug
set nocompatible              " be iMproved, required
filetype off                  " required

" set rtp+=~/.vim/autoload/plug.vim
call plug#begin('~/.vim/plugged')
EOF
    _grab_plug_commands "${script_dir}/plugins.vimrc" >> "${script_dir}/vimrctemp_vimplug"
#    sed -n "s/\(.*Plug '[^']*'\).*/\1/p" "${script_dir}/plugins.vimrc" >> "${script_dir}"/vimrctemp_vimplug
    if [ -f "${backup_home_vimrcpath}" ]
    then
      _grab_plug_commands "${backup_home_vimrcpath}" >> "${script_dir}/vimrctemp_vimplug"
      #sed -n "s/\(.*Plug '[^']*'\).*/\1/p" "${backup_home_vimrcpath}" >> "${script_dir}"/vimrctemp_vimplug
    fi
    echo 'call plug#end()
' >> "${script_dir}"/vimrctemp_vimplug
  fi

  if [ ${do_vundle} -ne 0 ]
  then
    vim +PluginUpdate "${vim_quit_command}" -u "${script_dir}/vimrctemp_vundle"
  fi

  if [ ${do_plug} -ne 0 ]
  then
    vim +PlugUpdate "${vim_quit_command}" -u "${script_dir}/vimrctemp_vimplug"
  fi

  if [ ${do_delete_tempfile} -ne 0 ]
  then
    rm -f "${script_dir}/vimrctemp_vundle"
    rm -f "${script_dir}/vimrctemp_vimplug"
  fi
}

# Script functions
function setup_directories() {
  if [ ! -d "${HOME}/.vim" ]
  then
    mkdir "${HOME}/.vim"
  fi
  
  if [ ! -d "${HOME}/.vim/bundle" ]
  then
    mkdir "${HOME}/.vim/bundle"
  fi
}

function setup_vimrc() {
  local do_vundle
  local do_plug
  local do_quit_vim
  local do_delete_tempfile

  do_vundle=${1:-1}
  do_plug=${2:-1}
  do_quit_vim=${3:-1}
  do_delete_tempfile=${4:-1}

  if [ ! "${actual_home_vimrcpath}" -ef "${script_vimrcpath}" ]
  then
    source_line="source ${script_vimrcpath}"
    read -r -d '' source_lines <<EOF
  ${source_line}
EOF
  if [ ! -f "${home_vimrcpath}" -o \( -L "${home_vimrcpath}" -a ! -f "${actual_home_vimrcpath}" \) ]
  then
    _pluginUp ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile}
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
  
        _pluginUp ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile}
        echo 'Updating .vimrc'
        echo "${source_lines}" | cat - "${backup_home_vimrcpath}" > "${actual_home_vimrcpath}"
      else
        echo 'Your .vimrc appears to source the repository .vimrc file already.'
        echo 'Installing plugins...'
        _pluginUp ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile}
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
}

function setup_youcompleteme() {
  local do_setup_ycm

  do_setup_ycm=${1:-1}
  if [ ${do_setup_ycm} -ne 0 ]
  then
    if [ -f "${script_dir}/setup_youcompleteme.sh" ]
    then
      echo 'Attempting to install youcompleteme.'
      "${script_dir}/setup_youcompleteme.sh"
    fi
  fi
}

# Command line
do_vundle=1
do_plug=1
do_quit_vim=1
do_delete_tempfile=1
do_setup_ycm=1

function usage() {
  cat <<EOF >&2
$(basename "${0}") [--no-vundle] [--no-plug] [--no-quit-vim] [--no-ycm] [--help]

  --no-vundle          - Do not install vundle plugins.
  --no-plug            - Do not install plug plugins.
  --no-quit-vim        - Do not quit vim after installing plugins.
  --no-ycm             - Do not setup youcompleteme.
  --no-delete-tempfile - Do not delete temporary files after setup.
  --help               - Show this help message.
EOF
}

ok_to_continue=0
declare -a args
args=( "${@}" )
args_length="${#args[@]}"

for (( i=0; i<args_length; i++ ))
do
  arg="${args[${i}]}"
  case "${arg}" in
    --no-vundle)
      do_vundle=0
      ;;
    --no-plug)
      do_plug=0
      ;;
    --no-quit-vim)
      do_quit_vim=0
      ;;
    --no-delete-tempfile)
      do_delete_tempfile=0
      ;;
    --no-ycm)
      do_setup_ycm=0
      ;;
    --help|-h|/?)
      usage
      exit 1
      ;;
    *)
      echo "Unexpected argument '${arg}'" >&2
      (( ok_to_continue++ ))
      ;;
  esac
done

if [ ${ok_to_continue} -ne 0 ]
then
  exit ${ok_to_continue}
fi

setup_directories
setup_vimrc ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile}
setup_youcompleteme ${do_setup_ycm}

