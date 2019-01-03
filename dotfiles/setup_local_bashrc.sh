#!/usr/bin/env bash
on_mac=0
os_name=$(uname -s)
if [ "${os_name}" == 'Darwin' ]
then
  on_mac=1
fi

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]; then
  _got_readlink=1
fi

_do_readlink() {
  if [ ${on_mac} -eq 1 ]
  then
    readlink "${1}"
  else
    readlink -f "${1}"
  fi
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

# Setup the core .bashrc (with a symlink)
if [ -f ~/code/mE/shscripts/marke_mac_bash.rc ] && [ ! -f ~/.bashrc ]
then
  ln -s ~/code/mE/shscripts/marke_mac_bash.rc ~/.bashrc
fi

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
    grep '.git-completion.bash' ~/.bashrc >/dev/null
    if [ ${?} -ne 0 ]; then
      add_git=1
    fi
  fi
fi

if [ ${add_git} -eq 1 ]; then
  echo '#https://git-scm.com/book/en/v1/Git-Basics-Tips-and-Tricks
source ~/.git-completion.bash' >>~/.bashrc
fi

#Deduce this script's directory
if [ -z ${BASH_SOURCE} ]; then
  script_dir=$(readlink -f $(dirname "${0}"))
else
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -f "${setup_script_dir}/setup_dotfiles.sh" ]
then
  "${setup_script_dir}/setup_dotfiles.sh"
fi

