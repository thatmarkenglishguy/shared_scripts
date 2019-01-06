#!/usr/bin/env bash

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

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

if ! which python3 2>&1 1>/dev/null
then
  echo 'Installing python3'
  brew install python3

  if ! which python3 2>&1 1>/dev/null
  then
    echo 'Failed to install python3 !.'
    exit 1
  fi
fi

python3_location=$(brew --prefix python3)
if [ -z "${python3_location}" ]
then
  echo 'brew --prefix python3 did not reveal the python3 location.' >&2
  exit 1
fi

python3_include_location=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")
python3_lib_dir=$(python3 -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
python3_lib_location=$(find "${python3_lib_dir}" -name 'libpython*m.dylib' -maxdepth 1 | tail -n 1)
python3_executable=$(python3 -c "import sys; print(sys.executable)")
#python3_home_location=$(find "${python3_location}/Frameworks/Python.framework/Versions" -maxdepth 1 -type d | tail -n 1)
#python_include_location=$(find "${python3_home_location}/include" -name 'python*' -maxdepth 1 -type d | tail -n 1)
#python_lib_location=$(find "${python3_home_location}/lib" -name 'libpython*m.dylib' -maxdepth 1 | tail -n 1)

# For compilers to find llvm you may need to set:
#   export LDFLAGS="-L/usr/local/opt/llvm/lib"
#   export CPPFLAGS="-I/usr/local/opt/llvm/include"

if ! which cmake 2>&1 1>/dev/null
then
  echo 'Installing cmake'
  brew install cmake
fi

YCM_DIR="${HOME}/.vim/bundle/YouCompleteMe"
YCM_THIRDPARTY_DIR="${YCM_DIR}/third_party/ycmd"

echo 'Setting up build directories.'
rm -rf ~/stuff/builds/ycm/ycm_build
mkdir -p ~/stuff/builds/ycm/ycm_build
pushd ~/stuff/builds/ycm/ycm_build
cmake -G "Unix Makefiles" . -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/cpp"

echo 'Building the ycm core...'
cmake --build . --target ycm_core --config Release

popd
echo 'Setting up regex build directories.'
rm -rf ~~/stuff/builds/ycm/regex_build
mkdir -p ~/stuff/builds/ycm/regex_build
pushd ~/stuff/builds/ycm/regex_build
cmake -G "Unix Makefiles" . ~ -DUSE_PYTHON2=OFF -DPATH_TO_LLVM_ROOT="${llvm_location}" -DPYTHON_INCLUDE_DIR="${python3_include_location}" -DPYTHON_LIBRARY="${python3_lib_location}" -DPYTHON_EXECUTABLE:FILEPATH="${python3_executable}" "${YCM_THIRDPARTY_DIR}/third_party/cregex"

echo 'Building the ycm regex engine...'
cmake --build . --target _regex --config Release

popd

# node.js
if ! which npm 2>&1 1>/dev/null
then
  echo 'Installing npm...'
  brew install npm
fi

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

# Java
echo 'Installing the Java engine...'

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

echo 'Running installer for extra components.'
pushd "${YCM_DIR}"
python3 ./install.py --skip-build --no-regex --ts-completer --java-completer
pushd

if ! which bear 2>&1 1>/dev/null
then
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

if ! which intercept-build 2>&1 1>/dev/null
then
  pip3 install --upgrade scan-build
  if ! which intercept-build 2>&1 1>/dev/null
  then
    echo 'Warning - failed to install intercept-build using "pip3 install scan-build"'
  fi
if

echo 'Done'

