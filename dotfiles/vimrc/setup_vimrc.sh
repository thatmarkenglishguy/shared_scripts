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

  if [ ! -d ~/.vim/bundle/Vundle.vim ]
  then
    if ! which git 2>&1 1>/dev/null
    then
      echo 'git not installed. Please install git.'
      case $(uname -a) in
        *Darwin*)
          brew install git
          ;;
        *Msys*|*Mingw*)
          pacman -S git
          ;;
        *)
          echo 'Unknown platform for git installation.'
          exit 1
          ;;
      esac
    fi

    echo 'Cloning Vundle...'
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  fi

  echo 'Installing Vim plugins'
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

  cat <<EOF >>"${script_dir}"/vimrctemp_vimplug
" vim-plug
set nocompatible              " be iMproved, required
filetype off                  " required

" set rtp+=~/.vim/autoload/plug.vim
call plug#begin('~/.vim/plugged')
EOF
  grep "Plug '" "${script_dir}/plugins.vimrc" >> "${script_dir}"/vimrctemp_vimplug
  if [ -f "${backup_home_vimrcpath}" ]
  then
    grep "Plug '" "${backup_home_vimrcpath}" >> "${script_dir}"/vimrctemp_vimplug
  fi
  echo 'call plug#end()
' >> "${script_dir}"/vimrctemp_vimplug

  # Start Waxme
#  echo vim +PluginUpdate -u "${script_dir}"/vimrctemp_vundle
#  echo vim +PlugUpdate -u "${script_dir}"/vimrctemp_vimplug
#  vim +PluginUpdate -u "${script_dir}"/vimrctemp_vundle
#  vim +PlugUpdate -u "${script_dir}"/vimrctemp_vimplug
#  vim "${script_dir}"/vimrctemp
#  exit
  # End Waxme

  vim +PluginUpdate +qall -u "${script_dir}"/vimrctemp_vundle
  vim +PlugUpdate +qall -u "${script_dir}"/vimrctemp_vimplug

  rm "${script_dir}"/vimrctemp_vundle
  rm "${script_dir}"/vimrctemp_vimplug
}

if [ ! -d ~/.vim ]
then
  mkdir ~/.vim
fi

if [ ! -d ~/.vim/bundle ]
then
  mkdir ~/.vim/bundle
fi

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

if [ -f "${script_dir}/setup_youcompleteme.sh" ]
then
  echo 'Attempting to install youcompleteme.'
  "${script_dir}/setup_youcompleteme.sh"
fi

