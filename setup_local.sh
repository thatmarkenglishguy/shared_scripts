#!/usr/bin/env bash

os_name='unknown'
#Linux f143b1d40484 5.10.124-linuxkit #1 SMP PREEMPT Thu Jun 30 08:18:26 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
case $(uname -a | tr '[:upper:]' '[:lower:]') in
  *msys*|*mingw64*)
    os_name='msys'
    ;;
  *cygwin*)
    os_name='cygwin'
    ;;
  *darwin*)
    os_name='darwin'
    ;;
  *linuxkit*)
    os_name='linux_kit'
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

# Start Command line
do_flamegraph=1
do_global_installs=0
do_user_installs=1

# Sort out global installs
case "${os_name}" in
  msys)
    do_global_installs=1
    ;;
  *)
    case "$(whoami)" in
      root|ROOT)
        do_global_installs=1
        do_user_installs=0
        ;;
      *)
        do_global_installs=0
        do_user_installs=1
        ;;
    esac
    ;;
esac

# Sort out specific settings
case "${os_name}" in
  linux_kit)
    do_flamegraph=0
    ;;
esac


function boolstring() {
  if [ ${1} -eq 0 ]
  then
    echo 'off'
  else
    echo 'on'
  fi
}

function inverseboolstring() {
  if [ ${1} -ne 0 ]
  then
    echo 'off'
  else
    echo 'on'
  fi
}

function check_ok() {
  if [ ${ok_to_continue} -ne 0 ]
  then
    exit ${ok_to_continue}
  fi
}

function usage() {
  cat <<EOF >&2
$(basename "${0}") [--no-flamegraph] [--global-installs] [--no-global-installs]

  --no-flamegraph       If specified, don't install cargo flamegraph which can be expensive. Defaults to $(boolstring ${do_flamegraph}).
  --global-installs     If specified, do global installs. Defaults to $(boolstring ${do_global_installs}).
  --no-global-installs  If specified, don't do global installs. Defaults to $(inverseboolstring ${do_global_installs}).
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
    --no-flamegraph|--no-flame-graph)
      do_flamegraph=0
      ;;
    --global-installs|--GLOBAL-INSTALLS)
      do_global_installs=1
      ;;
    --no-global-installs|--NO-GLOBAL-INSTALLS)
      do_global_installs=0
      ;;
    --help|-h|/?)
      usage
      exit 1
      ;;
    *)
      extra_args+=( ${arg} )
#      echo "Unexpected argument '${arg}'" >&2
#      (( ok_to_continue++ ))
      ;;
  esac
done

check_ok

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
# End Command line

# Main script
touch "${HOME}/.commonrc"

# Sort out flamegraph. It can be expensive so it's on command line.
# Note at the moment we do this whether do_global_installs is true or not.
if [ ${do_flamegraph} -eq 0 ]
then
  echo '# Skipping cargo flamegraph installation for setup_local.sh'
else
  echo '# Installing cargo flamegraph...' >&2
  # Note at the moment we do this whether do_global_installs is true or not.
  if ! command -v flamegraph &>/dev/null
  then
    cargo install flamegraph
  fi
fi

#set -x
if [ -f "${script_dir}/dotfiles/setup_local_bashrc.sh" ]
then
  echo 'Setting up bashrc.' >&2
  chmod 755 "${script_dir}/dotfiles/setup_local_bashrc.sh"
  "${script_dir}/dotfiles/setup_local_bashrc.sh" "${global_installs_arg}" "${extra_args[@]}"
  echo >&2
  echo
fi

if [ -f "${script_dir}/dotfiles/setup_local_zshrc.sh" ]
then
  echo 'Setting up zshrc.' >&2
  chmod 755 "${script_dir}/dotfiles/setup_local_zshrc.sh"
  "${script_dir}/dotfiles/setup_local_zshrc.sh" "${global_installs_arg}" "${extra_args[@]}"
  echo >&2
  echo
fi

if [ -f "${script_dir}/dotfiles/vimrc/setup_vimrc.sh" ]
then
  echo 'Setting up vimrc.' >&2
  chmod 755 "${script_dir}/dotfiles/vimrc/setup_vimrc.sh"
  "${script_dir}/dotfiles/vimrc/setup_vimrc.sh" "${global_installs_arg}" "${user_installs_arg}" "${extra_args[@]}"
  echo >&2
fi

if [ -f "${script_dir}/dotfiles/setup_local_gitconfig.sh" ]
then
  echo 'Setting up .gitconfig.' >&2
  chmod 755 "${script_dir}/dotfiles/setup_local_gitconfig.sh"
  "${script_dir}/dotfiles/setup_local_gitconfig.sh" "${global_installs_arg}" "${extra_args[@]}"
  echo >&2
  echo
fi

