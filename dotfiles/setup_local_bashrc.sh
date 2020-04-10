#!/usr/bin/env bash
on_mac=0
os_name=$(uname -s)
if [ "${os_name}" == 'Darwin' ]
then
  on_mac=1
fi

os_name='unknown'
case $(uname -a | tr '[:upper:]' '[:lower:]') in
  *mingw64*)
    os_name='msys'
    ;;
  *cygwin*)
    os_name='cygwin'
    ;;
  *darwin*)
    os_name='darwin'
    ;;
esac

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]; then
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

#Deduce this script's directory
if [ ${_got_readlink} -eq 1 ] && [ -z ${BASH_SOURCE} ]
then
  setup_script_dir=$(_do_readlink $(dirname "${0}"))
else
  setup_script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
set -x
# Do the basic minimum to get .bashrc loaded
add_to_profile=0

if [ ! -f ~/.bash_profile ]; then
  add_to_profile=1
else
  #TODO Switch ~ to ${HOME} ?
  grep '. ~/.bashrc' ~/.bash_profile >/dev/null
  if [ ${?} -ne 0 ]; then
    add_to_profile=1
  fi
fi

if [ ${add_to_profile} -eq 1 ]; then
  echo '# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi' >>~/.bash_profile
fi

case "${os_name}" in
  msys|cygwin)
    _setup_shscripts_dir='${HOME}/code/shscripts'
    source_line='source "${HOME}/code/shscripts/marke_mac_bash.rc"'
    ;;
  darwin)
    _setup_shscripts_dir='${HOME}/code/mE/shscripts'
    source_line='source "${HOME}/code/mE/shscripts/marke_mac_bash.rc"'
    ;;
#  *)
#    :
#    ;;
esac
source_line="source \"${_setup_shscripts_dir}/marke_mac_bash.rc\""
if ! grep "${source_line}" ~/.bashrc 2>&1 1>/dev/null
then
  echo "${source_line}" >> ~/.bashrc
fi

## Setup the core .bashrc (with a symlink)
#if [ -f ~/code/mE/shscripts/marke_mac_bash.rc ] && [ ! -f ~/.bashrc ]
#then
#  case "$(uname -a)" in 
#    *Msys*|*Mingw*)
#      source_line='source ${HOME}/code/shscripts/marke_mac_bash.rc'
#      if ! grep "${source_line}" ~/.bashrc 2>&1 1>/dev/null
#      then
#        echo "${source_line}" >> ~/.bashrc
#      fi
#      ;;
#    *Darwin*)
#      ln -s ~/code/mE/shscripts/marke_mac_bash.rc ~/.bashrc
#      ;;
##    *)
##      :
##      ;;
#  esac
#fi

# Sort out git completion
if [ ! -f ~/.git-completion.bash ]
then
  if which wget 1>/dev/null
  then
    wget -O ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  elif which curl 1>/dev/null
  then
    curl -o ~/.git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  else
    echo 'Unable to find wget or curl. Going to be hard to install git completion...' >&2
  fi
fi

add_git=0

if [ -f ~/.git-completion.bash ]
then
  if [ ! -f ~/.bashrc ]
  then
    add_git=1
  else
    if [ ! grep '.git-completion.bash' ~/.bashrc >/dev/null ]
    then
      add_git=1
    fi
  fi
fi

if [ ${add_git} -eq 1 ]
then
  echo '#https://git-scm.com/book/en/v1/Git-Basics-Tips-and-Tricks
source ~/.git-completion.bash' >>~/.bashrc
fi

if [ ! -d "~/code/thirdparty/shscripts/git-aware-prompt.git" ]
then
  mkdir -p ~/code/thirdparty/shscripts
  git clone git@github.com:jimeh/git-aware-prompt.git ~/code/thirdparty/shscripts/git-aware-prompt.git
fi

if [ ! -d "~/code/thirdparty/shscripts/gradle-completion.git" ]
then
  mkdir -p ~/code/thirdparty/shscripts
  git clone git@github.com:gradle/gradle-completion.git ~/code/thirdparty/shscripts/gradle-completion.git
fi

if [ -f "${setup_script_dir}/setup_dotfiles.sh" ]
then
  "${setup_script_dir}/setup_dotfiles.sh"
fi

if ! which src-hilite-lesspipe.sh 1>/dev/null 2>&1
then
  case $(os_name) in
    darwin)
      brew install source-highlight
      ;;
    msys)
      pacman --noconfirm -S mingw-w64-x86_64-source-highlight
      ;;
  esac
fi

