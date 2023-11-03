# :vim ft=shell

if [ -z ${BASH_SOURCE} ]; then
  _root_profile_bash_dir=$(readlink -f $(dirname "${0}"))
  _root_profile_bash_path=$(readlink -f "${0}")
else
  _root_profile_bash_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _root_profile_bash_path="${_root_profile_bash_dir}/$(basename ${BASH_SOURCE[0]})"
fi

# Import the __source_bash_files function
source "${_root_profile_bash_dir}/../shscripts/source_bash_files"
__source_bash_files "${_root_profile_bash_dir}" "${_root_source_bash_files_path}"
unset _root_profile_bash_dir
unset _root_profile_bash_path
unset -f __source_bash_files

