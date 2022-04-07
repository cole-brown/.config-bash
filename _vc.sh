
bap_ps1_vc_symbol="⎇"

bap_ps1_vc_ignored=()

bap_ps1_vc_reduced=()

# $1 is element to check
# $2 should be quoted array: "${array_var[@]}"
# Returns 0 if finds element, 1 if not.
bap_element_in_array () {
    local element
    local match="$1"
    # Shift match out of args and then for loop over the rest (the array).
    shift
    for element; do
        [[ "$element" == "$match" ]] && return 0
    done
    return 1
}


_bap_path_root_git=""
bap_path_root_git() {
    _bap_path_root_git=""
    # If a filepath was provided, use it's parent dir.
    local path="$1"
    if [[ -f "$path" ]]; then
        path="$(dirname "$path")"
    fi

    # Make sure we're in the dir.
    pushd "$path" >/dev/null 2>&1

    # Ask git for the root dir of the repo.
    _bap_path_root_git="$(git rev-parse --show-toplevel 2>/dev/null)"
    local -i exitcode=$?

    # Clean up.
    popd >/dev/null 2>&1

    # Return success/fail from git command.
    return $exitcode
}


_bap_path_root_vc=""
bap_path_in_vc() {
    local path="$1"
    _bap_path_root_vc=""

    # In Git?
    if bap_path_root_git "$path"; then
        _bap_path_root_vc="$_bap_path_root_git"
        return 0
    fi

    # Other version control systems checked here as needed.

    # Not in any version control.
    return 1
}


bap_ps1_vc_prompt() {
    # Explicitly ignored?
    if bap_element_in_array "$PWD" "${bap_ps1_vc_ignored[@]}"; then
        local bap_ps1_vc_value=" <ignored repo status>"

    # In Git?
    elif bap_path_root_git "$PWD"; then
        if bap_element_in_array "$PWD" "${bap_ps1_vc_reduced[@]}"; then
            local curr_dirty=GIT_PS1_SHOWDIRTYSTATE
            local curr_untracked=GIT_PS1_SHOWUNTRACKEDFILES

            export GIT_PS1_SHOWDIRTYSTATE=false
            export GIT_PS1_SHOWUNTRACKEDFILES=false

            # Slightly different from normal to indicate reduced?
            local bap_ps1_vc_value=" ..$(__git_ps1) .."

            export GIT_PS1_SHOWDIRTYSTATE=curr_dirty
            export GIT_PS1_SHOWUNTRACKEDFILES=curr_untracked

        else
            # Be normal.
            local bap_ps1_vc_value="${bap_ps1_vc_symbol}$(__git_ps1)"
        fi

        # Other version control systems checked here as needed.
    fi

    if [ ! -z "${bap_ps1_vc_value}" ]; then
        echo "${bap_ps1_vc_value}"
    fi
    # else nothing to report
}



bap_vc_setup() {
    #--------------
    # Version Control
    #--------------

    # Git
    #   - takes a small amount of time
    # export GIT_PS1_SHOWDIRTYSTATE=true
    #   - takes a larger amount of time
    # export GIT_PS1_SHOWUNTRACKEDFILES=true

    # Export bap_ps1_vc_prompt func so it can be run for every new prompt.
    export -f bap_ps1_vc_prompt
}
