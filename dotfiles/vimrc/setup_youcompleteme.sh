#!/usr/bin/env bash

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

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

function install_llvm() {
  case "${platform}" in
    darwin)
      if ! which llvm 2>&1 1>/dev/null
      then
        echo 'Installing llvm'
        brew install llvm
      else
        brew upgrade llvm
      fi

      llvm_location=$(brew --prefix llvm)
      if [ -z "${llvm_location}" ]
      then
        echo 'brew --prefix llvm did not reveal the llvm location ! Did the installation work ?' >&2
        exit 1
      fi
      ;;

    msys)
      #if ! which llvm &>/dev/null
      if ! which clang &>/dev/null
      then
        echo 'Installing llvm via clang'
        pacman -Su --noconfirm mingw64/mingw-w64-x86_64-clang
      else
        #echo 'Updating llvm via clang'
        #pacman -Su --noconfirm mingw64/mingw-w64-x86_64-clang
        :
      fi

      #llvm_location=$(dirname $(which llvm))
      llvm_location=$(dirname $(which clang))

      if [ ! -d "${llvm_location}" ]
      then
        echo 'Could not locate llvm on msys2'
        exit 1
      fi
      ;;
  esac
}

function install_python() {
  if ! which python3 2>&1 1>/dev/null
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
        ;;
      *)
        echo "Don't know how to install python3 on this platform: $(uname -a)"
        ;;
    esac

    if ! which python3 2>&1 1>/dev/null
    then
      echo 'Failed to install python3 !'
      exit 1
    fi
  fi
}

function detect_python() {
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

  python3_include_location=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
  python3_lib_dir=$(python3 -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
  case "${platform}" in
    darwin)
      python3_lib_location=$(find "${python3_lib_dir}" -name 'libpython*m.dylib' -maxdepth 1 | tail -n 1)
      ;;
    msys)
      python3_lib_location=$(find "${python3_lib_dir}" -maxdepth 2 -name 'libpython*.dll.a' | tail -n 1)
      ;;
  esac
  python3_executable=$(python3 -c "import sys; print(sys.executable)")
  #python3_home_location=$(find "${python3_location}/Frameworks/Python.framework/Versions" -maxdepth 1 -type d | tail -n 1)
  #python_include_location=$(find "${python3_home_location}/include" -name 'python*' -maxdepth 1 -type d | tail -n 1)
  #python_lib_location=$(find "${python3_home_location}/lib" -name 'libpython*m.dylib' -maxdepth 1 | tail -n 1)
}

function install_cmake() {
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
    esac
  fi
}

YCM_DIR="${HOME}/.vim/bundle/YouCompleteMe"
YCM_THIRDPARTY_DIR="${YCM_DIR}/third_party/ycmd"

function mend_ycm() {
  if [ -d "${YCM_THIRDPARTY_DIR}" ]
  then
    pushd "${YCM_THIRDPARTY_DIR}" >/dev/null
    git submodule sync --recursive
    git submodule update --init --recursive
    popd >/dev/null
  else
    echo "YCM_THIRDPARTY_DIR '${YCM_THIRDPARTY_DIR}' not found" >&2
  fi
}

function build_ycm_core() {
  local system_clang_path
  echo 'Setting up build directories.'
  rm -rf ~/stuff/builds/ycm/ycm_build
  mkdir -p ~/stuff/builds/ycm/ycm_build
  pushd ~/stuff/builds/ycm/ycm_build

  case "${platform}" in
    msys)
      system_clang_path=$(pacman -Ql mingw-w64-x86_64-clang | grep 'libclang.dll$' | cut -d' ' -f2)
      cmake -G 'Unix Makefiles' . -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" -DEXTERNAL_LIBCLANG_PATH="${system_clang_path}" "${YCM_THIRDPARTY_DIR}/cpp"
      ;;
    *)
      cmake -G 'Unix Makefiles' . -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"
      ;;
  esac

  echo 'Building the ycm core...'
  cmake --build . --target ycm_core --config Release

  popd
}

function build_ycm_regex() {
  echo 'Setting up regex build directories.'
  rm -rf ~/stuff/builds/ycm/regex_build
  mkdir -p ~/stuff/builds/ycm/regex_build
  pushd ~/stuff/builds/ycm/regex_build
  cmake -G "Unix Makefiles" . ~ -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/third_party/cregex"

  echo 'Building the ycm regex engine...'
  cmake --build . --target _regex --config Release

  popd
}

# node.js
function install_node() {
  if ! which npm 2>&1 1>/dev/null
  then
    echo 'Installing npm...'
    case "${platform}" in
      darwin)
        brew install npm
        ;;
      msys)
        mkdir -p "{$HOME}/code/thirdparty/node.js"
        (cd "${HOME}/code/thirdparty/node.js"; git clone git@github.com:nodejs/node.git node.git; cd node.git; echo 'Need to follow instructions in BUILDING.md')
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
  # Java
  echo 'Installing the Java engine...'

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
      export JAVA_HOME=$(ls -1 /c/java/openjdk/jdk-* | tail -n 1)
      export PATH="${JAVA_HOME}/bin:${PATH}"
      ;;
  esac
}

function install_rust() {
  if ! which cargo &>/dev/null
  then
    echo 'Installing rust...'
    case "${platform}" in
      darwin)
        curl https://sh.rustup.rs -sSf | sh
        ;;
      msys)
        npm -Su mingw64/mingw-w64-x86_64-rust
        ;;
      *)
        echo "Don't know how to install rust on platform '${platform}'"
        ;;
    esac
  fi

  if ! which cargo &>/dev/null
  then
    echo 'Failed to install rust.' >&2
  fi
}

function build_extra_components() {
  echo 'Running installer for extra components.'
  pushd "${YCM_DIR}"
  python3 ./install.py --skip-build --no-regex --ts-completer --java-completer --rust-completer
  pushd
}

function install_bear() {
  if ! which bear 2>&1 1>/dev/null
  then
    echo 'Installing bear'
    rm -rf ~/code/thirdparty/bear/build
    mkdir -p ~/code/thirdparty/bear/build
    pushd ~/code/thirdparty/bear
    git clone git@github.com:rizsotto/Bear.git
    pushd ~/code/thirdparty/bear/build
    cmake ../Bear
    make all
    make insatll
    echo 'Installed bear.'
    which bear
    popd
  fi
}

function install_intercept_build() {
  if ! which intercept-build 2>&1 1>/dev/null
  then
    echo 'Installing intercept-build'
    pip3 install --upgrade scan-build
    if ! which intercept-build 2>&1 1>/dev/null
    then
      echo 'Warning - failed to install intercept-build using "pip3 install scan-build"'
    fi
  fi
}

install_llvm
install_python
install_cmake
#set -x
detect_python
mend_ycm
build_ycm_core
build_ycm_regex
#set +x
install_node
verify_java
install_rust
build_extra_components
install_bear
install_intercept_build
echo 'Done'

