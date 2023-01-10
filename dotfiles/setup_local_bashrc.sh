#!/usr/bin/env bash
#on_mac=0
#os_name=$(uname -s)
#if [ "${os_name}" == 'Darwin' ]
#then
#  on_mac=1
#fi

_lsb_release_os_name() {
  if command -v lsb_release &>/dev/null
  then
    case $(lsb_release -d | tr '[:upper:]' '[:lower:]') in
      *ubuntu*)
        os_name='ubuntu'
        return 0
        ;;
    esac
  fi

  return 1
}

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
  *linuxkit*)
    os_name='linux_kit'
    ;;
  *wsl*)
   _lsb_release_os_name
   ;;
  *)
   _lsb_release_os_name
   ;;
esac

_got_readlink=0
which readlink >/dev/null
if [ $? -eq 0 ]
then
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
if [ ${_got_readlink} -eq 1 ] && [ -z "${BASH_SOURCE}" ]
then
  setup_script_dir=$(_do_readlink $(dirname "${0}"))
else
  setup_script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Command line
do_global_installs=1
do_user_installs=1

for arg in "${@}"
do
  case "${arg}" in
    --global-installs)
      do_global_installs=1
      ;;
    --no-global-installs)
      do_global_installs=0
      ;;
    --global-installs)
      do_global_installs=1
      ;;
    --no-global-installs)
      do_global_installs=0
      ;;
    *)
      echo "Ignoring unexpected setup_local_bashrc.sh arg ${arg}" >&2
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
#set -x
# Do the basic minimum to get .bashrc loaded
add_to_profile=0

if [ ! -f "${HOME}/.bash_profile" ]; then
  add_to_profile=1
else
  #TODO Switch ~ to ${HOME} ?
  grep '. ~/.bashrc' "${HOME}/.bash_profile" >/dev/null
  if [ ${?} -ne 0 ]; then
    add_to_profile=1
  fi
fi

if [ ${add_to_profile} -eq 1 ]; then
  echo '# Get the aliases and functions
if [ -f ~/.bashrc ]
then
  . ~/.bashrc
fi' >>"${HOME}/.bash_profile"
fi

echo "os name: ${os_name}"
case "${os_name}" in
  msys|cygwin|linux_kit)
    _setup_local_dir="${HOME}/code/onpath"
    _setup_shscripts_dir="${HOME}/code/shscripts"
#    source_line='source "${HOME}/code/shscripts/marke_mac_bash.rc"'
    ;;
  darwin)
    _setup_local_dir="${HOME}/mE/code/onpath"
    _setup_shscripts_dir="${HOME}/code/mE/shscripts"
#    source_line='source "${HOME}/code/mE/shscripts/marke_mac_bash.rc"'
    ;;
#  *)
#    :
#    ;;
esac

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

function _add_to_file() {
  local source_line
  local target
  local write_source_line
  source_line="${1}"
  target="${2:-${HOME}/.zshrc}"
  write_source_line=$(eval echo "${source_line}")

  if ! grep "${source_line}" "${target}" 2>&1 1>/dev/null
  then
    echo "${write_source_line}" >> "${target}"
  fi
}

_add_to_file "source \"${HOME}/.commonrc\"" "${HOME}/.bashrc"
case "${os_name}" in
  darwin)
    _add_to_file "source \"${setup_script_dir}/marke_msys_local_bash.rc\"" "${HOME}/.bashrc"
    _add_to_file "if \[ -f \"${_setup_shscripts_dir}/marke_mac_bash.rc\" \]\; then source \"${_setup_shscripts_dir}/marke_mac_bash.rc\" \; fi" "${HOME}/.bashrc"
    ;;
  msys|cygwin|linux_kit)
    _add_to_file "if \[ -f \"${_setup_local_dir}/dotfiles/marke_local_bash.rc\" \]\; then source \"${_setup_local_dir}/dotfiles/marke_local_bash.rc\" \; fi" "${HOME}/.bashrc"
    _add_to_file "source \"${setup_script_dir}/marke_msys_local_bash.rc\"" "${HOME}/.bashrc"
    ;;
  ubuntu)
    # TODO local stuff
    _add_to_file "source \"${setup_script_dir}/marke_msys_local_bash.rc\"" "${HOME}/.bashrc"
    ;;
esac
#source_line="source \"${_setup_shscripts_dir}/marke_mac_bash.rc\""
#if ! grep "${source_line}" ~/.bashrc 2>&1 1>/dev/null
#then
#  echo "${source_line}" >> ~/.bashrc
#fi

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

# Bash completion
case "${os_name}" in
  darwin)
    if [ -f $(brew --prefix)/etc/bash_completion ]
    then
      . $(brew --prefix)/etc/bash_completion
    fi
    ;;
esac

# kubectl completion
if command -v kubectl >/dev/null
then
  source /dev/stdin <<<"$(kubectl completion bash)"
  complete -F __start_kubectl k
  alias k='kubectl'
fi

# Sort out git completion
if [ ! -f "${HOME}/.git-completion.bash" ]
then
  if command -v wget 1>/dev/null
  then
    wget -O "${HOME}/.git-completion.bash" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  elif command -v curl 1>/dev/null
  then
    curl -o "${HOME}/.git-completion.bash" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  else
    echo 'Unable to find wget or curl. Going to be hard to install git completion...' >&2
  fi
fi

# Sort out flamegraph
if command -v flamegraph &>/dev/null
then
  flamegraph --completions bash > "${HOME}/.flamegraph-completion.bash"
fi


#add_git=0
#
#if [ -f ~/.git-completion.bash ]
#then
#  if [ ! -f ~/.bashrc ]
#  then
#    add_git=1
#  else
#    if [ ! grep '.git-completion.bash' ~/.bashrc >/dev/null ]
#    then
#      add_git=1
#    fi
#  fi
#fi
#
#if [ ${add_git} -eq 1 ]
#then
#  echo '#https://git-scm.com/book/en/v1/Git-Basics-Tips-and-Tricks
#source ~/.git-completion.bash' >>~/.bashrc
#fi

if [ ! -d "${HOME}/code/thirdparty/shscripts/git-aware-prompt.git" ]
then
  mkdir -p "${HOME}/code/thirdparty/shscripts"
  git clone "$(_github_repo_address jimeh/git-aware-prompt.git)" "${HOME}/code/thirdparty/shscripts/git-aware-prompt.git"
else
  pushd "${HOME}/code/thirdparty/shscripts/git-aware-prompt.git" &>/dev/null
  git fetch --prune
  git rebase
  popd &>/dev/null
fi

if [ ! -d "${HOME}/code/thirdparty/shscripts/gradle-completion.git" ]
then
  mkdir -p "${HOME}/code/thirdparty/shscripts"
  git clone "$(_github_repo_address gradle/gradle-completion.git)" "${HOME}/code/thirdparty/shscripts/gradle-completion.git"
else
  pushd "${HOME}/code/thirdparty/shscripts/gradle-completion.git" &>/dev/null
  git fetch --prune
  git rebase
  popd &>/dev/null
fi

if [ -f "${setup_script_dir}/setup_dotfiles.sh" ]
then
  "${setup_script_dir}/setup_dotfiles.sh" "${global_installs_arg}"
fi

if [ ${do_global_installs} -ne 0 ]
then
  if ! command -v src-hilite-lesspipe.sh 1>/dev/null 2>&1
  then
    case "${os_name}" in
      darwin)
        brew install source-highlight
        ;;
      msys)
        pacman --noconfirm -S mingw-w64-x86_64-source-highlight
        ;;
      ubuntu)
        sudo apt-get --assume-yes install source-highlight
        ;;
      *)
        echo "Don't know how to install source-highlight on '${os_name}'" >&2
        ;;
    esac
  fi
fi
