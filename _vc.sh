
_ps1_vc_symbol="⎇"

_ps1_vc_ignored=()

_ps1_vc_reduced=()

# $1 is element to check
# $2 should be quoted array: "${array_var[@]}"
# Returns 0 if finds element, 1 if not.
element_in () {
  local element
  local match="$1"
  # Shift match out of args and then for loop over the rest (the array).
  shift
  for element; do
    [[ "$element" == "$match" ]] && return 0
  done
  return 1
}


_path_root_git=""
path_root_git() {
  # If a filepath was provided, use it's parent dir.
  local path="$1"
  if [[ -f "$path" ]]; then
    path="$(dirname "$path")"
  fi

  # Make sure we're in the dir.
  pushd "$path" >/dev/null 2>&1

  # Ask git for the root dir of the repo.
  _path_root_git="$(git rev-parse --show-toplevel 2>/dev/null)"
  local -i exitcode=$?

  # Clean up.
  popd >/dev/null 2>&1

  # Return success/fail from git command.
  return $exitcode
}


path_in_vc() {
  local path="$1"

  # In Git?
  if path_root_git "$path"; then
    return 0
  fi

  # Other version control systems checked here as needed.

  # Not in any version control.
  return 1
}


_ps1_vc_() {
  # Explicitly ignored?
  if element_in "$PWD" "${_ps1_vc_ignored[@]}"; then
    local _ps1_vc_value=" <ignored repo status>"

  # In Git?
  elif path_root_git "$PWD"; then
    if element_in "$PWD" "${_ps1_vc_reduced[@]}"; then
      local curr_dirty=GIT_PS1_SHOWDIRTYSTATE
      local curr_untracked=GIT_PS1_SHOWUNTRACKEDFILES

      export GIT_PS1_SHOWDIRTYSTATE=false
      export GIT_PS1_SHOWUNTRACKEDFILES=false

      # Slightly different from normal to indicate reduced?
      local _ps1_vc_value=" ..$(__git_ps1) .."

      export GIT_PS1_SHOWDIRTYSTATE=curr_dirty
      export GIT_PS1_SHOWUNTRACKEDFILES=curr_untracked

    else
      # Be normal.
      local _ps1_vc_value="${_ps1_vc_symbol}$(__git_ps1)"
    fi

  # Other version control systems checked here as needed.
  fi

  if [ ! -z "${_ps1_vc_value}" ]; then
    echo "${_ps1_vc_value}"
  # else nothing to report
  fi
}


_ps1_vc_pre_() {
  # This works when it's used statically in PS1.
  # echo "${ps1_color_yellow}"

  # This is needed when called every prompt to build a PS1 string.
  echo -e "${ansi_color_yellow}"
}


_ps1_vc_post_() {
  # This works when it's used statically in PS1.
  # echo "${ps1_color_reset}"

  # This is needed when called every prompt to build a PS1 string.
  echo -e "${ansi_color_reset}"
}


_vc_setup() {
  if ! get_this_dir $1; then
    echo "_usr_env.sh can't find _colors.sh"
    return 1
  else
    source "$this_dir/_colors.sh"
    _colors_setup "$this_dir"
  fi

  #--------------
  # Version Control
  #--------------

  # Git
  #   - takes a small amount of time
  # export GIT_PS1_SHOWDIRTYSTATE=true
  #   - takes a larger amount of time
  # export GIT_PS1_SHOWUNTRACKEDFILES=true

  # Export _ps1_vc_ func so it can be run for every new prompt.
  export -f _ps1_vc_
}
