#!/usr/bin/env zsh
os_name='unknown'
case $(uname -a | tr '[:upper:]' '[:lower:]') in
  *mingw64*)
    os_name='msys'
    ;;
  *msys*)
    os_name='msys'
    ;;
  *cygwin*)
    os_name='cygwin'
    ;;
  *darwin*)
    os_name='darwin'
    ;;
esac

setup_script_dir="${0:A:h}"
# Do the basic minimum to get .zshrc loaded
add_to_profile=0

if [ ! -f "${HOME}/.zsh_profile" ]; then
  add_to_profile=1
else
  #TODO Switch ~ to ${HOME} ?
  grep '. ~/.zshrc' "${HOME}/.zsh_profile" >/dev/null
  if [ ${?} -ne 0 ]; then
    add_to_profile=1
  fi
fi

#if [ ${add_to_profile} -eq 1 ]; then
#  echo '# Get the aliases and functions
#if [ -f ~/.zshrc ]; then
#    . ~/.zshrc
#fi' >>"${HOME}/.zsh_profile"
#fi

case "${os_name}" in
  msys|cygwin)
    _setup_local_dir="${HOME}/code/onpath"
    _setup_shscripts_dir="${HOME}/code/shscripts"
#    source_line='source "${HOME}/code/shscripts/marke_mac_zsh.rc"'
    ;;
  darwin)
    _setup_local_dir="${HOME}/mE/code/onpath"
    _setup_shscripts_dir="${HOME}/code/mE/shscripts"
#    source_line='source "${HOME}/code/mE/shscripts/marke_mac_zsh.rc"'
    ;;
#  *)
#    :
#    ;;
esac

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
#    echo "${source_line}" >> "${target}"
  fi
}

_add_to_file 'autoload -Uz compinit && compinit' "${HOME}/.zshrc"

# Put our stuff in our own fpath directory: ./zsh
mkdir "${HOME}/.zsh" &>/dev/null
_add_to_file "fpath+=~/.zsh" "${HOME}/.zshrc"

case "${os_name}" in
  darwin)
    _add_to_file "source \"${setup_script_dir}/marke_msys_local_zsh.rc\"" "${HOME}/.zshrc"
    _add_to_file "source \"${_setup_shscripts_dir}/marke_mac_zsh.rc\"" "${HOME}/.zshrc"
    ;;
  msys|cygwin)
    _add_to_file "source \"${_setup_local_dir}/dotfiles/marke_local_zsh.rc\"" "${HOME}/.zshrc"
    _add_to_file "source \"${setup_script_dir}/marke_msys_local_zsh.rc\"" "${HOME}/.zshrc"
    ;;
esac

_add_to_file "source \"${setup_script_dir}/marke_msys_local_zsh_prompt.rc\"" "${HOME}/.zshrc"
_add_to_file "source \"${HOME}/.commonrc\"" "${HOME}/.zshrc"

#source_line="source \"${_setup_shscripts_dir}/marke_mac_zsh.rc\""
#if ! grep "${source_line}" ~/.zshrc 2>&1 1>/dev/null
#then
#  echo "${source_line}" >> ~/.zshrc
#fi

## Setup the core .zshrc (with a symlink)
#if [ -f ~/code/mE/shscripts/marke_mac_zsh.rc ] && [ ! -f ~/.zshrc ]
#then
#  case "$(uname -a)" in 
#    *Msys*|*Mingw*)
#      source_line='source ${HOME}/code/shscripts/marke_mac_zsh.rc'
#      if ! grep "${source_line}" ~/.zshrc 2>&1 1>/dev/null
#      then
#        echo "${source_line}" >> ~/.zshrc
#      fi
#      ;;
#    *Darwin*)
#      ln -s ~/code/mE/shscripts/marke_mac_zsh.rc ~/.zshrc
#      ;;
##    *)
##      :
##      ;;
#  esac
#fi

# Sort out git completion.
#
## This requires the bash git-completion...
if [ ! -f "${HOME}/.git-completion.bash" ]
then
  if which wget 1>/dev/null
  then
    wget -O "${HOME}/.git-completion.bash" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  elif which curl 1>/dev/null
  then
    curl -o "${HOME}/.git-completion.bash" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  else
    echo 'Unable to find wget or curl. Going to be hard to install git completion...' >&2
  fi
fi

if [ -f "${HOME}/.git-completion.bash" ]
then
  _add_to_file "zstyle ':completion:*:*:git:*' script ~/.git-completion.bash" "${HOME}/.zshrc"
fi

## and also zsh git-completion
if [ ! -f "${HOME}/.zsh/.git-completion.zsh" ]
then

  if which wget 1>/dev/null
  then
    wget -O "${HOME}/.zsh/.git-completion.zsh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
  elif which curl 1>/dev/null
  then
    curl -o "${HOME}/.zsh/.git-completion.zsh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
  else
    echo 'Unable to find wget or curl. Going to be hard to install git completion...' >&2
  fi
fi

#if [ ! -f "${HOME}/.git-completion.zsh" ]
#then
#  if which wget 1>/dev/null
#  then
#    wget -O "${HOME}/.git-completion.zsh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
#  elif which curl 1>/dev/null
#  then
#    curl -o "${HOME}/.git-completion.zsh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
#  else
#    echo 'Unable to find wget or curl. Going to be hard to install git completion...' >&2
#  fi
#fi

#add_git=0
#
#if [ -f ~/.git-completion.zsh ]
#then
#  if [ ! -f ~/.zshrc ]
#  then
#    add_git=1
#  else
#    if [ ! grep '.git-completion.zsh' ~/.zshrc >/dev/null ]
#    then
#      add_git=1
#    fi
#  fi
#fi
#
#if [ ${add_git} -eq 1 ]
#then
#  echo '#https://git-scm.com/book/en/v1/Git-Basics-Tips-and-Tricks
#source ~/.git-completion.zsh' >>~/.zshrc
#fi

# Note: No git aware prompt repo for zsh. Use a plugin.
if [ ! -d "${HOME}/code/thirdparty/shscripts/gradle-completion.git" ]
then
  mkdir -p "${HOME}/code/thirdparty/shscripts"
  git clone git@github.com:gradle/gradle-completion.git "${HOME}/code/thirdparty/shscripts/gradle-completion.git"
fi

# Sort out flamegraph

if ! command -v flamegraph &>/dev/null
then
  cargo install flamegraph
fi

if command -v flamegraph &>/dev/null
then
  flamegraph --completions zsh > "${HOME}/.zsh/.flamegraph-completion.zsh"
fi



if [ -f "${setup_script_dir}/setup_dotfiles.sh" ]
then
  "${setup_script_dir}/setup_dotfiles.sh"
fi

if ! which src-hilite-lesspipe.sh 1>/dev/null 2>&1
then
  case ${os_name} in
    darwin)
      brew install source-highlight
      ;;
    msys)
      pacman --noconfirm -S mingw-w64-x86_64-source-highlight
      ;;
  esac
fi

