#!/usr/bin/env bash

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

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

thirdparty_dir="${script_dir}"
ok_to_continue=0

while [ "${thirdparty_dir##*/}" != 'code' ]
do
  thirdparty_dir="${thirdparty_dir%/*}"
  if [ "${thirdparty_dir}" == '/' ]
  then
    echo 'Unable to find code directory' >&2
    (( ++ok_to_continue ))
  fi
done


if [ ${ok_to_continue} -ne 0 ]
then
  exit ${ok_to_continue}
fi

thirdparty_dir="${thirdparty_dir}/thirdparty"

ccls_root_dir="${thirdparty_dir}/ccls"
ccls_git_dir="${ccls_root_dir}/ccls.git"
llvm_prefix="$(brew --prefix llvm)"

function build_ccls() {
  echo '# Building ccls'
  if [ ! -d "${ccls_git_dir}" ]
  then
    mkdir -p "${ccls_root_dir}"
    git clone --depth=1 --recursive https://github.com/MaskRay/ccls "${ccls_git_dir}"
  else
    cd "${ccls_git_dir}"
    git fetch --prune
    git rebase --autostash
  fi

  case "${platform}" in
    darwin)
      cd "${ccls_git_dir}"
      cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="${llvm_prefix}/lib/cmake"
      cmake --build Release
      cd -
      ;;
    *)
      echo "I don't know how to compile ccls on '${platform}'" >&2
      (( ++ok_to_continue ))
      ;;
  esac
}

function install_ccls() {
  echo '# Installing ccls'
  case "${platform}" in
    darwin)
      cd "${ccls_git_dir}"
      cmake --build Release --target install
      cd -
      ;;
    *)
      echo "I don't know how to install ccls on '${platform}'" >&2
      ;;
  esac
}

ccls_config_dir="${HOME}/.vim"
ccls_config_path="${ccls_config_dir}/coc-settings.json"

function configure_ccls() {
  echo '# Configuring CCLS'
  if [ -f "${ccls_config_path}" ]
  then
    echo "${ccls_config_path} already exists. I won't overwrite it." >&2
    (( ++ok_to_continue ))
  else
    cat <<-'EOF' >>"${ccls_config_path}"
  "languageserver": {
    "ccls": {
      "command": "ccls",
      "args": ["--log-file=/tmp/ccls.log", "-v=1"],
      "filetypes": ["c", "cc", "cpp", "c++", "objc", "objcpp"],
      "rootPatterns": [".ccls", "compile_commands.json", ".vim/", ".git/", ".hg/"],
      "initializationOptions": {
         "cache": {
           "directory": "/tmp/ccls"
         },
         "client": {
          "snippetSupport": true
         },
         // This will re-index the file on buffer change which is definitely a performance hit. See if it works for you
//         "index": {
//           "onChange": true
//         },
         // This is mandatory!
         "highlight": { "lsRanges" : true }
       }
    }
  }
EOF
  fi
}

function install_linting() {
  echo '# Installing Linting'
  pip3 install cpplint
}

# TODO I made this up
ccls_config_dir="${HOME}/.config/ccls"
# TODO I have no idea. There must be a global setting for this
ccls_header_path="${ccls_config_dir}/.ccls"
function make_ccls_header_file() {
  if [ ! -f "${ccls_header_path}" ]
  then
    echo "# Making ccls header file '${ccls_header_path}'"
    mkdir -p "${ccls_config_dir}"
    case "${platform}" in
      darwin)
        # TODO Some magic with g++ -E -x c++ - -v < /dev/null
        # see https://medium.com/geekculture/configuring-neovim-for-c-development-in-2021-33f86296a8b3
        g++ -E -x c++ - -v < /dev/null 2>&1 |
          sed -n '/#include </,/End of search list/ {
1d
# Skip lines starting with include
/.*#include </d
# Skip lines starting with End
/End of search list/d
# Drop the descriptive text from Frameworks and branch to next cycle
s/[[:space:]]*\(.*\)[[:space:]]*(framework[[:space:]]*directory)/\1/p ; t
# Print everything else
s/[[:space:]]*\(.*\)/\1/p
}' > "${ccls_header_path}"
        ;;
      *)
        echo "I don't know how to get headers on platform '${platform}' for ccls file ${ccls_header_path}" >&2
        (( ++ok_to_continue ))
        ;;
    esac
  else
    echo "# ccls header file '${ccls_header_path}' already exists. I won't overwrite it."
  fi
}

function finish_up() {
  echo '# Done'
}

build_ccls
install_ccls
configure_ccls
install_linting
make_ccls_header_file
finish_up
