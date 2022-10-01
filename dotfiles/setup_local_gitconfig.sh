#!/usr/bin/env bash

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

function _add_to_file() {
  local source_line
  local target
  source_line="${1}"
  target="${2:-${HOME}/.zshrc}"

  if ! grep "${source_line}" "${target}" 2>&1 1>/dev/null
  then
    echo "${source_line}" >> "${target}"
  fi
}

function _prepend_to_file() {
  local source_line
  local target
  source_line="${1}"
  target="${2:-${HOME}/.zshrc}"

  if ! grep "${source_line}" "${target}" 2>&1 1>/dev/null
  then
    echo "${source_line}" | cat - "${target}" | dd conv=notrunc of="${target}" &>/dev/null
  fi
}
set -x
#TODO Make this work - [include] is causing problems for grep
_prepend_to_file "       path = ${script_dir}/.gitconfig" "${HOME}/.gitconfig"
_prepend_to_file '[include]' "${HOME}/.gitconfig" 
#_add_to_file '[include]'$'\n'"
#        path = ${script_dir}/.gitconfig" "${HOME}/.gitconfig"
set +x
