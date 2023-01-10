#!/usr/bin/env bash

# Where am I ?
_lsb_release_os_name() {
  if command -v lsb_release &>/dev/null
  then
    case $(lsb_release -d | tr '[:upper:]' '[:lower:]') in
      *ubuntu*)
        os_name='ubuntu'
        return 0
        ;;
    esac
  fi

  return 1
}

os_name='unknown'

case $(uname -a | tr '[:upper:]' '[:lower:]') in
  *darwin*)
    os_name='darwin'
    ;;
  *cygwin*)
    os_name='cygwin'
    ;;
  *msys*|*mingw*)
    os_name='msys'
    ;;
  *linuxkit*)
    os_name='linux_kit'
    ;;
  *wsl*)
   _lsb_release_os_name
   ;;
  *)
    if ! _lsb_release_os_name
    then
      echo 'Unrecognised platform ' >&2
      uname -a
    fi
    ;;
esac

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]
then
  _got_readlink=1
fi

_do_readlink() {
  case "${os_name}" in
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
script_vimrcpath="${script_dir}"/root.vimrc
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

function _plug_command() {
  local vim_quit_command
  vim_quit_command="${1}"
  set -x
  vim "${@:2}" "${vim_quit_command}" -u "${script_dir}/vimrctemp_vimplug"
  set +x
}

# Internal functions
_pluginUp() {
  local do_vundle
  local do_plug
  local do_quit_vim
  local do_delete_tempfile
  local do_plugins
  local do_global_installs
  local do_user_installs
  local vim_quit
  local vim_quit_command

  do_vundle=${1:-1}
  do_plug=${2:-1}
  do_quit_vim=${3:-1}
  do_delete_tempfile=${4:-1}
  do_plugins=${5:-1}
  do_global_installs=${6:-1}
  do_user_installs=${7:-1}
  vim_quit='qall'
  vim_quit_command="+${vim_quit}"

  if [ ${do_quit_vim} -eq 0 ]
  then
    vim_quit=''
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
    if ! command -v git 2>&1 1>/dev/null
    then
      echo 'git not installed. Please install git.'
      case "${os_name}" in
        darwin)
          brew install git
          ;;
        msys)
          pacman -S git
          ;;
        linux_kit)
          if [ ${do_global_installs} -ne 0 ]
          then
            if command -v microdnf &>/dev/null
            then
              microdnf install --assume-yes git
            else
              dnf install --assume-yes git
            fi
          else
            echo "Skipping global install of git" >&2
          fi
          ;;
        ubuntu)
          if [ ${do_global_installs} -ne 0 ]
          then
            if command -v apt-get &>/dev/null
            then
              sudo apt-get install --assume-yes git
            else
              echo 'No apt-get so not sure how to do git installation on ubuntu' >&2
            fi
          else
            echo "Skipping global install of git" >&2
          fi
          ;;
        *)
          echo 'Unknown platform for git installation.'
          exit 1
          ;;
      esac
    fi

    if ! command -v cmake 2>&1 1>/dev/null
    then
      echo 'cmake not installed. Please install cmake.'
      case "${os_name}" in
        darwin)
          brew install cmake
          ;;
        msys)
          pacman -S cmake
          ;;
        linux_kit)
          if [ ${do_global_installs} -ne 0 ]
          then
            if command -v microdnf &>/dev/null
            then
              microdnf install --assume-yes cmake
            else
              dnf install --assume-yes cmake
            fi
          else
            echo "Skipping global install of cmake" >&2
          fi
          ;;
        ubuntu)
          if [ ${do_global_installs} -ne 0 ]
          then
            if command -v apt-get &>/dev/null
            then
              sudo apt-get install --assume-yes cmake
            else
              echo 'No apt-get so not sure how to install cmake on ubuntu' >&2 
            fi
          else
            echo "Skipping global install of cmake" >&2
          fi
          ;;
        *)
          echo 'Unknown platform for cmake installation.'
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
    grep "Plugin '" "${script_dir}/vundle.vimrc" | if [ ${do_user_installs} -ne 0 ]; then cat ; else grep --invert-match --ignore-case 'YouCompleteMe'; fi >> "${script_dir}"/vimrctemp_vundle
    if [ -f "${backup_home_vimrcpath}" ]
    then
      set -x
      grep "Plugin '" "${backup_home_vimrcpath}" | if [ ${do_user_installs} -ne 0 ]; then cat ; else grep --invert-match --ignore-case 'YouCompleteMe'; fi >> "${script_dir}"/vimrctempvundle
      set +x
      cat "${script_dir}"/vimrctempvundle
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
set nocompatible              " be iMproved, required
let path = expand('<sfile>:h')
exec 'source' path . '/platform.vimrc'
exec 'source' path . '/settings.vimrc'
exec 'source' path . '/plugins.vimrc'
EOF
#    cat <<EOF >>"${script_dir}"/vimrctemp_vimplug
#
#" vim-plug
#set nocompatible              " be iMproved, required
#filetype off                  " required
#
#" set rtp+=~/.vim/autoload/plug.vim
#call plug#begin('~/.vim/plugged')
#EOF
#    _grab_plug_commands "${script_dir}/plugins.vimrc" >> "${script_dir}/vimrctemp_vimplug"
##    sed -n "s/\(.*Plug '[^']*'\).*/\1/p" "${script_dir}/plugins.vimrc" >> "${script_dir}"/vimrctemp_vimplug
#    if [ -f "${backup_home_vimrcpath}" ]
#    then
#      _grab_plug_commands "${backup_home_vimrcpath}" >> "${script_dir}/vimrctemp_vimplug"
#      #sed -n "s/\(.*Plug '[^']*'\).*/\1/p" "${backup_home_vimrcpath}" >> "${script_dir}"/vimrctemp_vimplug
#    fi
#    echo 'call plug#end()
#' >> "${script_dir}"/vimrctemp_vimplug
  fi

  if [ ${do_vundle} -ne 0 ]
  then
    vim +PluginUpdate "${vim_quit_command}" -u "${script_dir}/vimrctemp_vundle"
  fi

  if [ ${do_plug} -ne 0 ]
  then
    _plug_command "${vim_quit_command}" +PlugUpdate +'CocUpdateSync' 

    if [ ${do_user_installs} -eq 0 ]
    then
      echo "Skipping installing CoC plugins" >&2
    else
      # coc-pyright seems really expensive to check up on...
      if [ ! -d "${HOME}/.config/coc/extensions/node_modules/coc-pyright" ]
      then
        _plug_command "${vim_quit_command}" +'CocInstall coc-pyright'
      fi
      # The other lighter-weight plugins
      # #coc-rust-rls seems to be deprecated. TODO Remove this comment and the line below if that's all good.
      #_plug_command "${vim_quit_command}" +'CocInstall coc-rust-analyzer|CocInstall coc-rust-rls|CocInstall coc-json'
      
      _plug_command "${vim_quit_command}" +'CocInstall -sync coc-json coc-rust-analyzer'
    fi
  fi

  setup_native_plugins ${do_plugins}

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

  # Note 'pack' is mandatory. 'plugins' is an optional name I picked after reading
  # https://github.com/udalov/kotlin-vim
  if [ ! -d "${HOME}/.vim/pack/plugins" ]
  then
    mkdir -p "${HOME}/.vim/pack/plugins"
  fi
}

function setup_external_files() {
  case "${os_name}" in
    cygwin)
      mkdir -p ~/.vim/colors
      wget https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim -O ~/vim/colors/solarized.vim
      ;;
  esac
}

function setup_vimrc() {
  local do_vundle
  local do_plug
  local do_quit_vim
  local do_delete_tempfile
  local do_plugins
  local do_global_installs
  local do_user_installs

  do_vundle=${1:-1}
  do_plug=${2:-1}
  do_quit_vim=${3:-1}
  do_delete_tempfile=${4:-1}
  do_plugins=${5:-1}
  do_global_installs=${6:-1}
  do_user_installs=${7:-1}

  if [ ! "${actual_home_vimrcpath}" -ef "${script_vimrcpath}" ]
  then
    source_line="source ${script_vimrcpath}"
    read -r -d '' source_lines <<EOF
  ${source_line}
EOF
  if [ ! -f "${home_vimrcpath}" -o \( -L "${home_vimrcpath}" -a ! -f "${actual_home_vimrcpath}" \) ]
  then
    _pluginUp ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile} ${do_plugins} ${do_global_installs} ${do_user_installs}
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
  
        _pluginUp ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile} ${do_plugins} ${do_global_installs} ${do_user_installs}
        echo 'Updating .vimrc'
        echo "${source_lines}" | cat - "${backup_home_vimrcpath}" > "${actual_home_vimrcpath}"
      else
        echo 'Your .vimrc appears to source the repository .vimrc file already.'
        echo 'Installing plugins...'
        _pluginUp ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile} ${do_plugins} ${do_global_installs} ${do_user_installs}
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
  local global_installs_arg
  local user_installs_arg

  do_setup_ycm=${1:-1}
  global_installs_arg="${2---global-installs}"
  user_installs_arg="${3---user-installs}"

  if [ ${do_setup_ycm} -ne 0 ]
  then
    if [ -f "${script_dir}/setup_youcompleteme.sh" ]
    then
      echo 'Attempting to install youcompleteme.'
      chmod 755 "${script_dir}/setup_youcompleteme.sh"
      "${script_dir}/setup_youcompleteme.sh" "${global_installs_arg}" "${user_installs_arg}" "${extra_args[@]}"
    fi
  fi
}

function setup_coc() {
  local do_setup_coc
  local global_installs_arg
  local user_installs_arg

  do_setup_coc=${1:-1}
  global_installs_arg="${2---global-installs}"
  user_installs_arg="${3---user-installs}"

  if [ ${do_setup_coc} -ne 0 ]
  then
    if [ -f "${script_dir}/setup_coc.sh" ]
    then
      echo "Attempting to install CoC."
      chmod 755 "${script_dir}/setup_coc.sh"
      "${script_dir}/setup_coc.sh" "${global_installs_arg}" "${user_installs_arg}" "${extra_args[@]}"
    fi
  fi
}

function setup_native_plugins() {
  local do_setup_plugins

  do_setup_plugins=${1:-1}
  if [ ${do_setup_plugins} -ne 0 ]
  then
    if [ ! -d "${HOME}/.vim/pack/plugins/start/kotlin-vim/.git" ]
    then
      git clone https://github.com/udalov/kotlin-vim.git "${HOME}/.vim/pack/plugins/start/kotlin-vim"
    else
      pushd "${HOME}/.vim/pack/plugins/start/kotlin-vim" &>/dev/null
      git fetch --prune
      git rebase
      popd &>/dev/null
    fi
  fi
}

# Command line
do_vundle=1
do_plug=1
do_plugins=1
do_quit_vim=1
do_delete_tempfile=1
do_setup_ycm=1
do_setup_coc=0 # Don't want CoC and YouCompleteMe to compete
do_global_installs=1
do_user_installs=1

case "${os_name}" in
  darwin)
    do_setup_ycm=0
    do_setup_coc=1
    ;;
  linux_kit)
    do_setup_ycm=1
    do_setup_coc=1
    if [ $(whoami) = 'root' ]
    then
      do_global_installs=1
      do_user_installs=0
    else
      do_global_installs=0
      do_user_installs=1
    fi
    ;;
  ubuntu)
    do_setup_ycm=0
    do_setup_coc=1
    ;;
esac

function usage() {
  cat <<EOF >&2
$(basename "${0}") [--no-vundle] [--no-plug] [--no-quit-vim] [--no-ycm] [--coc] [--no-coc] [--no-delete-tempfile] [--global-installs] [--no-global-installs] [--help]

  --no-vundle          - Do not install vundle plugins.
  --no-plug            - Do not install plug plugins.
  --no-plugins         - Do not install vim native plugins.
  --no-quit-vim        - Do not quit vim after installing plugins.
  --no-ycm             - Do not setup youcompleteme.
  --coc                - Setup CoC.
  --no-coc             - Do not setup CoC.
  --no-delete-tempfile - Do not delete temporary files after setup.
  --global-installs    - If specified, install global dependencies.
  --no-global-installs - If specified, do not install global dependencies.
  --user-installs      - If specified, install user dependencies.
  --no-user-installs   - If specified, do not install user dependencies.
  --help               - Show this help message.
EOF
}


declare -a args
args=( "${@}" )
args_length="${#args[@]}"
declare -a extra_args
extra_args=()
ok_to_continue=0

for (( i=0; i<args_length; i++ ))
do
  arg="${args[${i}]}"
  case "${arg}" in
    --coc)
      do_setup_coc=1
      ;;
    --no-vundle)
      do_vundle=0
      ;;
    --no-plug)
      do_plug=0
      ;;
    --no-plugins)
      do_plugins=0
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
    --no-coc)
      do_setup_coc=0
      ;;
    --global-installs)
      do_global_installs=1
      ;;
    --no-global-installs)
      do_global_installs=0
      ;;
    --user-installs)
      do_user_installs=1
      ;;
    --no-user-installs)
      do_user_installs=0
      ;;
    --help|-h|/?)
      usage
      exit 1
      ;;
    *)
      extra_args+=( ${arg} )
#      echo "Unexpected setup_vimrc.sh argument: '${arg}'" >&2
#      (( ok_to_continue++ ))
      ;;
  esac
done

if [ ${ok_to_continue} -ne 0 ]
then
  exit ${ok_to_continue}
fi

if [ ${do_global_installs} -eq 0 ]
then
  global_installs_arg='--no-global-installs'
else
  global_installs_arg='--global-installs'
fi

if [ ${do_user_installs} -eq 0 ]
then
  user_installs_arg='--no-user-installs'
else
  user_installs_arg='--user-installs'
fi

# Main script
setup_directories
setup_external_files
setup_vimrc ${do_vundle} ${do_plug} ${do_quit_vim} ${do_delete_tempfile} ${do_plugins} ${do_global_installs} ${do_user_installs}
setup_youcompleteme ${do_setup_ycm} "${global_installs_arg}" "${user_installs_arg}"
setup_coc ${do_setup_coc} "${global_installs_arg}" "${user_installs_arg}"

