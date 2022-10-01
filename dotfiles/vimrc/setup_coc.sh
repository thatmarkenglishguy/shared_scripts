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

function check_ok() {
  if [ ${ok_to_continue} -ne 0 ]
  then
    echo "Something bad happened. Bailing..." >&2
    exit ${ok_to_continue}
  fi
}

thirdparty_dir="${thirdparty_dir}/thirdparty"

ccls_root_dir="${thirdparty_dir}/ccls"
ccls_git_dir="${ccls_root_dir}/ccls.git"

function build_ccls() {
  echo '# Building ccls'
  check_ok
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
      llvm_prefix="$(brew --prefix llvm)"
      cd "${ccls_git_dir}"
      cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="${llvm_prefix}/lib/cmake"
      cmake --build Release
      cd -
      ;;
    msys)
      if ! command -v clang
      then
        echo "I can't find clang" >&2
        (( ++ok_to_continue ))
      else
        cd "${ccls_git_dir}"
        #cmake -H. -BRelease -G Ninja -DCMAKE_CXX_FLAGS=-D__STDC_FORMAT_MACROS
        #pacman -Sy --needed --noconfirm \
        pacman -Sy --needed --noconfirm \
          mingw-w64-x86_64-clang \
          mingw-w64-x86_64-clang-tools-extra \
          mingw-w64-x86_64-clang-analyzer \
          mingw64/mingw-w64-x86_64-polly \
          mingw-w64-x86_64-cmake \
          mingw-w64-x86_64-jq \
          mingw-w64-x86_64-ninja \
          mingw-w64-x86_64-ncurses \
          mingw-w64-x86_64-rapidjson \
          mingw-w64-x86_64-mlir
        cmake -H. -BRelease -G Ninja
        windows_user="$(cmd /c "echo %COMPUTERNAME%/%USERNAME%")"
        echo "windows user: ${windows_user}"
        runas "${windows_user}" ninja -C Release
        #cmake -H. -GNinja -BRelease -DCMAKE_BUILD_TYPE=Release
        #cmake --build Release
        cd -
      fi
      ;;
    *)
      echo "I don't know how to compile ccls on '${platform}'" >&2
      (( ++ok_to_continue ))
      ;;
  esac
}

function install_ccls() {
  local win_ccls_git_dir
  local win_cmake_path

  echo '# Installing ccls'
  check_ok
  case "${platform}" in
    darwin)
      cd "${ccls_git_dir}"
      cmake --build Release --target install
      cd -
      ;;
    msys)
      # TODO Install with CMAKE_INSTALL_PREFIX of /usr/local so it ends up in /usr/local/bin
      # I've tried -DCMAKE_INSTALL_PREFIX which doesn't work
      # I've tried --install-prefix /usr/local which doesn't work
      # I am not enjoying CMake
      cmake -DCMAKE_INSTALL_PREFIX= --build Release --target install
      win_ccls_git_dir="$(cygpath -w "${ccls_git_dir}")"
      win_cmake_path="$(cygpath -w "$(which cmake)")"
      cat <<-EOF >&2
If you want to install into standard windows program files directory (which won't be on the path) then...
Many apologies but you may have to open a command prompt with administrator priviliges to install ccls.exe :-(
I can't find a way to elevate from msys cleanly.
To install ccls...
* Run an elevated command prompt (right click on the command prompt icon and click "Run as administrator")
* cd ${win_ccls_git_dir}
* ${win_cmake_path} --build Release --target install
EOF
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
  check_ok
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

function usage() {
  cat <<-EOF
First attempt at building/setting up coc for vim.
EOF
}

## Command line
verbose=0
dry_run=0
declare -a args
args=( "${@}" )
args_length=${#args[@]}

function take_an_argument() {
  # Globals:
  #  i [in/out]            - Current argument index.
  #  ok_exit_code [in/out] - Current exit code.
  #  args[in]              - Array of command line arguments.
  #  args_length[in]       - Number of command line arguments.
  # Parameters:
  #  1 - Name of variable to set.
  #  2 - Parameter name in use.
  local var_name
  local param_name
  local current_value

  var_name="${1}"
  param_name="${2}"
  current_value="${!var_name}"

  if [ -n "${current_value}" ]
  then
    echo "${param_name} already set to '${current_value}'" >&2
    (( ++ok_exit_code ))
  else
    (( i++ ))
    if (( i < args_length ))
    then
      eval ${var_name}=${args[${i}]}
    else
      echo "${param_name} parameter expects an argument." >&2
      (( ++ok_exit_code ))
    fi
  fi
}

for (( i=0; i<args_length; ++i ))
do
  arg="${args[${i}]}"
  case "${arg}" in
    -v|--verbose)
      verbose=1
      ;;
    --dry|--dryrun|--dry-run)
      dry_run=1
      ;;
    -h|--help|/?)
      usage
      exit 1
      ;;
    *)
      echo "Unexpected argument '${arg}'" >&2
      exit 2
      ;;
  esac
done

build_ccls
install_ccls
configure_ccls
install_linting
make_ccls_header_file
finish_up
