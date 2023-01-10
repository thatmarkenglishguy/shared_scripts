#!/usr/bin/env bash

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

function _prepend_to_file() {
  # 1 - Text to add.
  # 2 - File to write to.
  # 3 - [optional] Pattern to search for. If not specified, use ${1}.
  local source_line
  local target
  local pattern
  local cat_args
  source_line="${1}"
  target="${2:-${HOME}/.gitconfig}"
  declare -a cat_args
  cat_args=( '-' )

  if [ -f "${target}" ]
  then
    cat_args+=( "${target}" )
  fi

  if [ -n "${3}" ]
  then
    pattern="${3}"
  else
    pattern="${source_line}"
  fi

  if [ ! -f "${target}" ] || ! grep "${pattern}" "${target}" 2>&1 1>/dev/null
  then
    echo "${source_line}" | cat "${cat_args[@]}" | dd conv=notrunc of="${target}" &>/dev/null
  fi
}

# Command line
do_global_installs=1

for arg in "${@}"
do
  case "${arg}" in
    --global-installs)
      do_global_installs=1
      ;;
    --no-global-installs)
      do_global_installs=0
      ;;
    *)
      echo "Ignoring unexpected setup_local_gitconfig.sh arg ${arg}" >&2
      ;;
  esac
done

if [ ${do_global_installs} -eq 0 ]
then
  global_installs_arg='--no-global-installs'
else
  global_installs_arg='--global-installs'
fi
# End Command line

# Main script
_prepend_to_file "[include]
	path = ${script_dir}/.gitconfig
" "${HOME}/.gitconfig" "path[[:space:]]*=[[:space:]]*${script_dir}/.gitconfig"

