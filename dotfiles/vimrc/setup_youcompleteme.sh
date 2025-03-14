#!/usr/bin/env bash

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

ok_to_continue=0
uname_result=$(uname -a | tr '[:upper:]' '[:lower:]') 
platform=unknown
sub_platform=unknown

case "${uname_result}" in 
  *darwin*)
    platform=darwin
    sub_platform=darwin
    ;;

  *cygwin*)
    platform=cygwin
    echo 'Cygwin not currently supported. Please install Msys2, launch an Msys2/Mingw64 terminal, and run this script from there.'
    ;;

  *msys*)
    case "${uname_result}" in
      *mingw*)
        platform=msys
        sub_platform=mingw
        ;;
      *)
        platform=msys
        sub_platform=msys
#        (( ++ok_to_continue ))
#        cat <<-EOF >&2
#Platform result suggests msys2 terminal, not msys2/Mingw64 terminal as required.
#Presuming Msys2 is installed to standard location, please try launching from Windows Console as
#> c:\msys64\msys2_shell.cmd -mingw64 -full-path
#Then cd $(pwd) and re-run this script.
#
#Note platform result: '${uname_result}'.
#EOF
        ;;
    esac
    ;;
  *mingw*)
    (( ++ok_to_continue ))
    echo "Platform result suggests Mingw64 without Msys2/Mingw64 terminal as required. Please install Msys2 and launch a Mingw64 console from there."
    echo "Platform result: '${uname_result}'"
    ;;
  *penguin*)
    platform='penguin'
    sub_platform='penguin'
    ;;
  *linuxkit*)
    platform=linux_kit
    sub_platform=linux_kit
    ;;
  *)
    echo 'Unrecognised platform ' >&2
    uname -a
    ;;
esac

function install_llvm() {
  local do_llvm
  local do_global_installs
  local do_user_installs
  do_llvm=${1:-1}
  do_global_installs=${2:-1}
  do_user_installs=${3:-1}

  case "${platform}" in
    darwin)
      if [ ${do_llvm} -eq 1 ]
      then
        if ! which llvm 2>&1 1>/dev/null
        then
          echo 'Installing llvm'
          brew install llvm
        else
          brew upgrade llvm
        fi
      fi

      llvm_location=$(brew --prefix llvm)
#      llvm_location='/usr/local/Cellar/llvm/11.0.0' # HACKKKKKKKKKKKKKK
      echo "llvm_location: ${llvm_location}"
      if [ -z "${llvm_location}" ]
      then
        echo 'brew --prefix llvm did not reveal the llvm location ! Did the installation work ?' >&2
        exit 1
      fi
      ;;

    msys-with-local-clang) #Never set, just here for posterity
      if ! which clang &>/dev/null
      then
        echo 'Installing llvm via clang'
        pacman -Su --noconfirm mingw64/mingw-w64-x86_64-clang
      else
        #echo 'Updating llvm via clang'
        #pacman -Su --noconfirm mingw64/mingw-w64-x86_64-clang
        :
      fi

      llvm_location=$(dirname $(which clang))

      if [ ! -d "${llvm_location}" ]
      then
        echo 'Could not locate llvm on msys2'
        exit 1
      fi
      ;;

    msys)
      echo 'Rather then trying to install llvm and clang, going to rely on YCM to do it itself via --clangd-completer' >&2
      ;;
  esac
}

function install_python() {
  if [ ${1:-1} -ne 1 ]; then return; fi
  local do_global_installs
  local do_user_installs

  do_global_installs=${2:-1}
  do_user_installs=${3:-1}

  if ! command -v python3 2>&1 1>/dev/null
  then
    echo 'Installing python3'
    case "${platform}" in
      darwin)
        brew install python3
        brew link python
        ;;
      msys)
        pacman -Su --noconfirm python3
        pacman -Su --noconfirm mingw64/mingw-w64-x86_64-python3-pip
        case ${sub_platform} in
          msys)
            python3 -m ensurepip --default-pip
            python3 -m pip install --upgrade pip
            ;;
        esac
        ;;
      *)
        if [ ${do_global_installs} -ne 0 ]
        then
          echo "Don't know how to install python3 on this platform: $(uname -a)"
        fi
        ;;
    esac

    if [ ${do_global_installs} -ne 0 ] && ! command -v python3 2>&1 1>/dev/null
    then
      echo 'Failed to install python3 !'
      exit 1
    fi
  fi
}

function detect_python() {
  local override_msys
  local description
  local python_exe_path
  override_python_exe=${1:-0}
  description="${2}"
  if [ -n "${description}" ]
  then
    description=" ${description}"
  fi

  python_exe_path='python3'

  case "${platform}" in
    msys)
      case "${sub_platform}" in
        mingw)
          if [ -f /usr/bin/python3 ]
          then
            if [ ${override_python_exe} -ne 0 ]
            then
              echo "Using the msys python3 installation on mingw64${description}" >&2
              python_exe_path=/usr/bin/python3
            else
              echo "Using the standard python3 installation on mingw64${description}" >&2
            fi
          fi
          ;;
      esac
      ;;
  esac

  case "${platform}" in
    darwin)
      # Todo - I don't think we need python3_location.
      python3_location=$(brew --prefix python3)
      if [ -z "${python3_location}" ]
      then
        echo 'brew --prefix python3 did not reveal the python3 location.' >&2
        exit 1
      fi
      ;;
  esac
#msys
#python3_include_location: '/usr/include/python3.8'
#python3_lib_dir         : '/usr/lib'
#python3_lib_location    : '/usr/lib/libpython3.8.dll.a'

#mingw
#python3_include_location: 'C:/msys64/mingw64/include/python3.8'
#python3_lib_dir         : 'C:/msys64/mingw64/lib'
#python3_lib_location    : 'C:/msys64/mingw64/lib/libpython3.8.dll.a'

  python3_include_location=$(${python_exe_path} -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
  python3_lib_dir=$(${python_exe_path} -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
  case "${platform}" in
    darwin)
      python3_lib_location=$(find "${python3_lib_dir}" -name 'libpython*m.dylib' -maxdepth 1 | tail -n 1)
      if [ -z "${python3_lib_location}" ]
      then
        python3_lib_location=$(find "${python3_lib_dir}" -name 'libpython*.dylib' -maxdepth 1 | tail -n 1)
      fi
      ;;
    msys)
      python3_lib_location=$(find "${python3_lib_dir}" -maxdepth 2 -name 'libpython*.dll.a' | tail -n 1)
      ;;
  esac
  python3_executable=$(${python_exe_path} -c "import sys; print(sys.executable)")

  echo "python3_include_location: '${python3_include_location}'"
  echo "python3_lib_dir         : '${python3_lib_dir}'"
  echo "python3_lib_location    : '${python3_lib_location}'"
  #python3_home_location=$(find "${python3_location}/Frameworks/Python.framework/Versions" -maxdepth 1 -type d | tail -n 1)
  #python_include_location=$(find "${python3_home_location}/include" -name 'python*' -maxdepth 1 -type d | tail -n 1)
  #python_lib_location=$(find "${python3_home_location}/lib" -name 'libpython*m.dylib' -maxdepth 1 | tail -n 1)
}

function install_cmake() {
  local do_global_installs
  local do_user_installs

  do_global_installs=${1:-1}
  do_user_installs=${2:-1}

  # For compilers to find llvm you may need to set:
  #   export LDFLAGS="-L/usr/local/opt/llvm/lib"
  #   export CPPFLAGS="-I/usr/local/opt/llvm/include"

  if ! which cmake 2>&1 1>/dev/null
  then
    echo 'Installing cmake'
    case "${platform}" in
      darwin)
        brew install cmake
        ;;
      msys)
        #pacman -Ss cmake
        pacman -Ss mingw64/mingw-w64-x86_64-cmake
        ;;
      linux_kit)
        if [ ${do_global_installs} -ne 0 ]
        then
          if command -v microdnf >/dev/null
          then
            microdnf --assumeyes update && microdnf --assumeyes install cmake
          else
            dnf --assumeyes update && microdnf --assumeyes install cmake
          fi
        fi # do_global_installs
    esac
  fi
}

YCM_DIR="${HOME}/.vim/bundle/YouCompleteMe"
YCM_THIRDPARTY_DIR="${YCM_DIR}/third_party/ycmd"

function mend_ycm() {
  if [ ${1:-1} -ne 1 ]; then return; fi
  local do_user_installs
  do_user_installs=${2:-1}

  if [ ${do_user_installs} -eq 0 ]
  then
    echo "Skipping mending YouCompleteMe code" >&2
    return 0
  fi

  if [ -d "${YCM_THIRDPARTY_DIR}" ]
  then
    echo 'Mending YouCompleteMe' >&2
    pushd "${YCM_THIRDPARTY_DIR}" >/dev/null
    git submodule sync --recursive
    git submodule update --init --recursive

    popd >/dev/null
  else
    echo "YCM_THIRDPARTY_DIR '${YCM_THIRDPARTY_DIR}' not found" >&2
  fi
}

function fixup_cmake_files() {
  local do_user_installs
  do_user_installs=${1:-1}

  if [ ${do_user_installs} -eq 0 ]
  then
    echo "Skipping fixing YouCompleteMe cmake files" >&2
    return 0
  fi

  case "${platform}" in
    darwin)
      if ! grep 'CMAKE_OSX_DEPLOYMENT_TARGET' "${YCM_THIRDPARTY_DIR}/cpp/CMakeLists.txt"  >/dev/null
      then
        # Here:     ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/CMakeLists.txt
        # Not here: ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/CMakeLists.txt
        echo "Adding 'set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)' to ${YCM_THIRDPARTY_DIR}/cpp/CMakeLists.txt"
        sed -i'' -e '/^if[[:space:]][[:space:]]*([[:space:]][[:space:]]*APPLE[[:space:]][[:space:]]*)/ {
a\
\ \ set( CMAKE_OSX_DEPLOYMENT_TARGET 10.15 )
}' "${YCM_THIRDPARTY_DIR}/cpp/CMakeLists.txt"
      fi

      # WIP so not yet writing to file. Haven't decided where to put this yet.
      # Initially wrote it above if ( MSVC )...
      if ! grep 'CMP0066' "${YCM_THIRDPARTY_DIR}/cpp/ycm/CMakeLists.txt" >/dev/null
      then
        cat <<-EOF
# Honor per-config flags in try_compile() source-file signature.
# Introduced in CMake 3.7.
# On a Mac this enables the filesystem detection mechanism.
cmake_policy(SET CMP0066 NEW)
EOF
      fi

      if ! grep 'CMP0056' "${YCM_THIRDPARTY_DIR}/cpp/ycm/CMakeLists.txt" >/dev/null
      then
        cat <<-EOF
# Honor link flags in try_compile() source-file signature.
# Introduced in CMake 3.2.
# On a Mac this enables the filesystem detection mechanism.
cmake_policy(SET CMP0056 NEW)
EOF
      fi
      ;;
  esac
}

function build_ycm_core() {
  if [ ${1:-1} -ne 1 ]; then return; fi
  local do_user_installs

  do_user_installs=${2:-1}

  if [ ${do_user_installs} -eq 0 ]
  then
    echo "Skipping building YouCompleteMe core" >&2
    return 0
  fi

  local system_clang_path
  local build_dir
  build_dir=~/stuff/builds/ycm/ycm_build/${sub_platform}

  echo 'Setting up build directories.'
  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"
  pushd "${build_dir}"

  case "${platform}" in
    msys-with-local-clang) #Never set, just here for posterity
      #This builds, but we're moving away from installing clang to relying on --clangd-completer
      system_clang_path=$(pacman -Ql mingw-w64-x86_64-clang | grep 'libclang.dll$' | cut -d' ' -f2)
      cmake -G 'Unix Makefiles' . -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" -DEXTERNAL_LIBCLANG_PATH="${system_clang_path}" "${YCM_THIRDPARTY_DIR}/cpp"
#      cmake -G 'Unix Makefiles' . -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" -DEXTERNAL_LIBCLANG_PATH="${system_clang_path}" "${YCM_THIRDPARTY_DIR}/cpp"
      ;;

    msys)
     cmake -G 'Unix Makefiles' . "${YCM_THIRDPARTY_DIR}/cpp"
#     cmake -G 'Unix Makefiles' . -DUSE_PYTHON2=OFF -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"
      ;;
    *)
      set -x
      # This works from the command line, but not from this script...
#      cmake -G 'Unix Makefiles' . -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT=/usr/local/opt/llvm -DPYTHON_INCLUDE_DIR=/usr/local/Cellar/python@3.9/3.9.0_2/Frameworks/Python.framework/Versions/3.9/include/python3.9 -DPYTHON_LIBRARY=/usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/lib/libpython3.9.dylib -DPYTHON_EXECUTABLE:FILEPATH=/usr/local/opt/python@3.9/bin/python3.9 /Users/markenglish/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
      
      # Seeing
      # CMake Error at /usr/local/Cellar/cmake/3.17.3/share/cmake/Modules/FindPackageHandleStandardArgs.cmake:164 (message):
      # Could NOT find PythonLibs (missing: PYTHON_LIBRARIES) (found suitable
      # version "3.8.3", minimum required is "3.5")
      #cmake -G 'Unix Makefiles' . -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"
      cmake -G 'Unix Makefiles' . -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"
      # Makes no difference to rpath problem
      #cmake -G 'Unix Makefiles' . -DDYLD_LIBRARY_PATH="${llvm_location}/lib" -DEXTERNAL_LIBCLANG_PATH="${llvm_location}/lib/libclang.dylib" -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"
      # Seems to make no difference
      #cmake -G 'Unix Makefiles' . -DUSE_SYSTEM_LIBCLANG=1 -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"
      set +x
      ;;
  esac

  echo "building the ycm core in $(pwd)..."
  set -x
  cmake --build . --target ycm_core --config Release
  set +x
  popd
}

function build_ycm_regex() {
  if [ ${1:-1} -ne 1 ]; then return; fi
  local do_user_installs
  do_user_installs=${2:-1}

  if [ ${do_user_installs} -eq 0 ]
  then
    echo "Skipping building YouCompleteMe regex." >&2
    return 0
  fi

  echo 'Setting up regex build directories.'
  rm -rf ~/stuff/builds/ycm/regex_build/${sub_platform}
  mkdir -p ~/stuff/builds/ycm/regex_build/${sub_platform}
  pushd ~/stuff/builds/ycm/regex_build/${sub_platform}
  #cmake -G "Unix Makefiles" . ~ -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/third_party/cregex"
  cmake -G "Unix Makefiles" . ~ -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/third_party/cregex"

  echo 'building the ycm regex engine...'
  cmake --build . --target _regex --config Release

  popd
}

# node.js
function install_node() {
  local do_global_installs
  local do_user_installs

  do_global_installs=${1:-1}
  do_user_installs=${2:-1}

  if ! command -v npm 2>&1 1>/dev/null
  then
    echo 'Installing npm...'
    case "${platform}" in
      darwin)
        brew install npm
        ;;
      msys)
        mkdir -p "{$HOME}/code/thirdparty/node.js"
        (cd "${HOME}/code/thirdparty/node.js"; git clone "$(_github_repo_address nodejs/node.git)" node.git; cd node.git; echo 'Need to follow instructions in BUILDING.md')
        ;;
      *)
        if [ ${do_global_installs} -ne 0 ]
        then
          echo "Skipping node installation on ${platform}" >&2
        fi
        ;;
    esac
  fi
}

# 
# echo 'Installing the JavaScript and TypeScript engine...'
# pushd "${YCM_THIRDPARTY_DIR}"
# npm install -g --prefix third_party/tsserver typescript
# popd

# # Rust
# if ! which rustup 2>&1 1>/dev/null
# then
#   echo 'Installing rust'
#   curl https://sh.rustup.rs -sSf | sh
# fi
#  
# pushd "${YCM_THIRDPARTY_DIR}/third_party/racerd"
# cargo build --release
# popd

function verify_java() {
  if [ ${1:-1} -ne 1 ]; then return; fi

  if which java &>/dev/null
  then
    if java -version 2>&1 | grep 1.8 &>/dev/null
    then
      return
    fi
  fi

  # Java
  echo 'Locating Java 8 engine...'

  case "${platform}" in
    darwin)
      export JAVA_HOME=$(find /Library/Java/JavaVirtualMachines/ -name 'jdk1.8*' -maxdepth 1 | tail -n 1)/Contents/Home
      if [ "${JAVA_HOME}" == '/Contents/Home' ]
      then
        echo 'Java 8 not installed ?'
      else
        #  pushd "${YCM_THIRDPARTY_DIR}/third_party/eclipse.jdt.ls/target/repository"
        #  dq='"'
        #  jdt_file=$(curl -s http://download.eclipse.org/jdtls/snapshots/?d | grep -oh 'jdt-language-server-[0-9.-]\+.tar.gz' | sort | uniq | tail -n 1)
        #  jdt_url=$(curl -s http://download.eclipse.org/jdtls/snapshots/?d | grep -oh "href=['${dq}].*${jdt_file}['${dq}]")
        #  # Remove href=' from front and ' from end
        #  jdt_url="${jdt_url:6:${#jdt_url}-7}"
        #  curl -L -O "${jdt_url}"
        #  tar -zxv "${jdt_file}"
        #  popd
        echo 'Java 8 installed.'
      fi
      ;;
    msys)
      # Just have a look in the well known location
      #export JAVA_HOME=$(ls -1 /c/java/openjdk/jdk-* | tail -n 1)
      export JAVA_HOME=$(ls -1 -d /c/java/jdk-1.8* | tail -n 1)
      export PATH="${JAVA_HOME}/bin:${PATH}"
      ;;
  esac
}

function install_rust() {
  if [ ${1:-1} -ne 1 ]; then return; fi
  local do_global_installs
  local do_user_installs

  do_global_installs=${2:-1}
  do_user_installs=${3:-1}

  if ! command -v cargo &>/dev/null
  then
    echo 'Installing rust...'
    case "${platform}" in
      darwin)
        curl https://sh.rustup.rs -sSf | sh
        ;;
      msys)
        echo 'Should be using rustup for this too, but there are issues...' >&2
        #https://gitter.im/Valloric/YouCompleteMe?at=5e24a4be7148837898a2a874
        #Does the plugin install it's own rustup or rust toolchain ?
        #Yes, but there's a problem with that. rls can't find the standard library when installed to a custom directory for some reason. The workaround is to rustup component add rust-src.
        #pacman -Su mingw64/mingw-w64-x86_64-rust
        ;;
      *)
        if [ ${do_global_installs} -ne 0 ]
        then
          echo "Don't know how to install rust on platform '${platform}'"
        fi
        ;;
    esac
  fi

  if ! command -v cargo &>/dev/null
  then
    echo 'Failed to install rust.' >&2
  fi
}

function build_extra_components() {
  local do_java
  local do_node
  local do_rust
  local do_user_installs
  local install_args

  do_java=${1:-1}
  do_node=${2:-1}
  do_rust=${3:-1}
  do_user_installs=${4:-1}
  declare -a install_args
  install_args=()

  if [ ${do_user_installs} -eq 0 ]
  then
    echo "Skipping building extra YouCompleteMe components." >&2
    return 0
  fi

  if [ ${do_java} -ne 0 ]
  then
    install_args+=( '--java-completer' )
  fi

  if [ ${do_node} -ne 0 ]
  then
    install_args+=( '--ts-completer' )
  fi

  if [ ${do_rust} -ne 0 ]
  then
    install_args+=( '--rust-completer' )
  fi

  #python3 ./install.py --skip-build --no-regex --ts-completer --java-completer --rust-completer
  if [ ${#install_args[@]} -gt 0 ]
  then
    pushd "${YCM_DIR}"
    echo 'Running installer for extra components.'
    case "${platform}" in
      msys)
        install_args+=( '--clangd-completer' )
        ;;
      *)
        :
        ;;
    esac
    echo "python3 ./install.py --skip-build ${install_args[@]}" >&2
    python3 ./install.py --skip-build "${install_args[@]}"
    popd
  fi
#  case "${platform}" in
#    msys)
#      #python3 ./install.py --skip-build --no-regex --ts-completer --java-completer --rust-completer
#      python3 ./install.py --skip-build --no-regex --clangd-completer
#      python3 ./install.py --skip-build --no-regex --rust-completer
#      ;;
#    *)
#      python3 ./install.py --skip-build --no-regex --ts-completer --java-completer --rust-completer
#      ;;
#  esac
}

function _github_repo_address() {
  local input
  input="${1}"

  if [ -z "${input}" ]
  then
    echo 'Expected input for _github_repo_address' >&2
    return 1
  elif [ -d "${HOME}/.ssh" ] && find "${HOME}/.ssh" -name '*.pub' | grep --quiet '.'
  then
    echo "git@github.com:${input}"
  else
    echo "https://github.com/${input}"
  fi
}

function install_bear() {
  if [ ${1:-1} -ne 1 ]; then return 0; fi

  local do_global_installs
  local do_user_installs
  do_global_installs=${2:-1}
  do_user_installs=${3:-1}

  if [ ${do_global_installs} -ne 0 ]
  then
    if ! command -v bear 2>&1 1>/dev/null
    then
      if [ ! -d "${HOME}/code/thirdparty/bear/Bear.git" ]
      then
        echo 'Downloading bear'
        mkdir -p "${HOME}/code/thirdparty/bear"
        pushd "${HOME}/code/thirdparty/bear" >/dev/null
        git clone "$(_github_repo_address rizsotto/Bear.git)"
      else
        echo 'Updating bear'
        pushd "${HOME}/code/thirdparty/bear/Bear.git" >/dev/null
        git fetch --prune
        git rebase
      fi
      popd >/dev/null
      rm -rf "${HOME}/code/thirdparty/bear/build"
      mkdir -p "${HOME}/code/thirdparty/bear/build"
      pushd "${HOME}/code/thirdparty/bear/build" >/dev/null
      echo 'Installing bear'
      cmake ../Bear
      make all
      make install
      echo 'Installed bear.'
      command -v bear
      popd >/dev/null
    fi
  fi # do_global_installs
}

function install_intercept_build() {
  local do_global_installs
  local do_user_installs
  do_global_installs=${1:-1}
  do_user_installs=${2:-1}

  if [ ${do_global_installs} -ne 0 ]
  then
    if ! command -v intercept-build 2>&1 1>/dev/null
    then
      echo 'Installing intercept-build'
      pip3 install --upgrade scan-build
      if ! command -v intercept-build 2>&1 1>/dev/null
      then
        echo 'Warning - failed to install intercept-build using "pip3 install scan-build"'
      fi
    fi
  fi # do_global_installs
}

do_python=1
do_java=1
do_node=1
do_rust=1
do_ycm=1
do_mend_ycm=1
do_ycm_regex=1
do_override_mingw_python3_on_msys=1
do_llvm=1
do_bear=1
do_global_installs=1
do_user_installs=1

case "${platform}" in
  msys)
    do_java=0
    do_node=0
    do_rust=0
    case "${sub_platform}" in
      msys)
        do_mend_ycm=1
        ;;
      mingw)
        do_mend_ycm=0
        ;;
    esac
    ;;
  linux_kit)
    do_bear=0
    if [ $(whoami) = 'root' ]
    then
      do_global_installs=1
      do_user_installs=0
    else
      do_global_installs=0
      do_user_installs=1
    fi
    ;;
  *)
    :
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

function usage() {
  cat <<EOF >&2
$(basename "${0}") [--[no-]python] [--[no-]java] [--[no-]node] [--[no-]rust] [--no-ycm] [--no-ycm-regex]


  --python             If specified, install Python3 if necessary. Defaults to $(boolstring ${do_python}).
  --java               If specified, install the java support in YouCompleteMe. Defaults to $(boolstring ${do_java}).
  --node               If specified, install Node, and the plugin for YouCompleteMe. Defaults to $(boolstring ${do_node}).
  --rust               If specified, install rust, and the plugin for YouCompleteMe. Defaults to $(boolstring ${do_rust}).
  --mend-ycm           If specified, run 'git submodule update --init --recursive' after installing YouCompleteMe. Defaults to $(boolstring ${do_mend_ycm}).
  --override-mingw     -with-msys
                       If specified on mingw platform with msys python3 available, build against msys platform. Defaults to $(boolstring ${do_override_mingw_python3_on_msys}).
  --bear               If specified, install bear. Defaults to $(boolstring ${do_bear}).

  --no-python          Don't try to install Python3. Defaults to $(inverseboolstring ${do_python}).
  --no-java            Don't install the java support in YouCompleteMe. Defaults to $(inverseboolstring ${do_java}).
  --no-node            Don't install Node, and the plugin for YouCompleteMe. Defaults to $(inverseboolstring ${do_node}).
  --no-rust            Don't install rust, and the plugin for YouCompleteMe. Defaults to $(inverseboolstring ${do_rust}).
  --no mend-ycm        Don't run 'git submodule update --init --recursive' after installing YouCompleteMe. Defaults to $(inverseboolstring ${do_mend_ycm}).
  --no-ycm             Don't build YouCompleteMe. Defaults to $(inverseboolstring ${do_ycm}).
  --no-ycm-regex       Don't build YouCompleteMe regex. Defaults to $(inverseboolstring ${do_ycm_regex}).
  --no-override-mingw-with-msys
                       Don't override mingw python3 installation with msys. Defaults to $(inverseboolstring ${do_override_mingw_python3_on_msys}).
  --no-bear            Don't install bear. Defaults to $(inverseboolstring ${do_bear}).
  --no-llvm            Don't install llvm. Defaults to $(inverseboolstring ${do_llvm}).
  --global-installs    If specified, install global dependencies.
  --no-global-installs If specified, do not install global dependencies.
  --user-installs      If specified, install user dependencies.
  --no-user-installs   If specified, do not install user dependencies.

Notes:
Java, node and rust all work on Mac, but are in progress for Msys/Mingw64.
Sometimes msys seems to need --mend-ycm. Sometimes it doesn't.
Java8 is merely detected, not installed.
EOF

  case "${platform}" in
    darwin)
      echo 'On Mac, will search for Java 8 in /Library/Java/JavaVirtualMachines' >&2
      ;;
    msys)
      echo 'On Windows using Msys/Mingw64, will search for Java 8 in /c/java for a directory starting "jdk-1.8".' >&2
      ;;
    *)
      echo "Unrecognised platform '${platform}'. Please ensure Java 8 is on the path, and JAVA_HOME points to its location." >&2
      ;;
  esac
}

declare -a args
args=( "${@}" )
args_length="${#args[@]}"

for (( i=0; i<args_length; i++ ))
do
  arg="${args[${i}]}"

  case "${arg}" in
    --llvm)
      do_llvm=1
      ;;
    --python)
      do_python=1
      ;;
    --java)
      do_java=1
      ;;
    --node)
      do_node=1
      ;;
    --rust)
      do_rust=1
      ;;
    --mend-ycm)
      do_mend_ycm=1
      ;;
    --override-mingw-with-msys)
      do_override_mingw_python3_on_msys=1
      ;;
    --bear)
      do_bear=1
      ;;

    --no-python)
      do_python=0
      ;;
    --no-java)
      do_java=0
      ;;
    --no-node)
      do_node=0
      ;;
    --no-rust)
      do_rust=0
      ;;
    --no-mend-ycm)
      do_mend_ycm=0
      ;;
    --no-ycm)
      do_ycm=0
      ;;
    --no-ycm-regex)
      do_ycm_regex=0
      ;;
    --no-override-mingw-with-msys)
      do_override_mingw_python3_on_msys=0
      ;;
    --no-bear)
      do_bear=0
      ;;
    --no-llvm)
      do_llvm=0
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
      echo "Ignoring argument '${arg}'" >&2
      (( ok_to_continue++ ))
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

case "${platform}" in
  msys)
    :
    ;;
  *)
    install_llvm ${do_llvm} ${do_global_installs} ${do_user_installs}
    ;;
esac

install_python ${do_python} ${do_global_installs} ${do_user_installs}
install_cmake ${do_global_installs} ${do_user_installs}
detect_python ${do_override_mingw_python3_on_msys} 'building YouCompleteMe core'
mend_ycm ${do_mend_ycm} ${do_user_installs}
fixup_cmake_files ${do_user_installs}
build_ycm_core ${do_ycm} ${do_user_installs}
detect_python 0 'building YouCompleteMe regex'
build_ycm_regex ${do_ycm_regex} ${do_user_installs}
install_node ${do_node} ${do_global_installs} ${do_user_installs}
verify_java ${do_java}
install_rust ${do_rust} ${do_global_installs} ${do_user_installs}
build_extra_components ${do_java} ${do_node} ${do_rust} ${do_user_installs}
case "${platform}" in
  msys)
    :
    ;;
  *)
    install_bear ${do_bear} ${do_global_installs} ${do_user_installs}
    ;;
esac
install_intercept_build ${do_global_installs} ${do_user_installs}
echo 'Done'

