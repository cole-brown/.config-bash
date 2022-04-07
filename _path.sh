# Source this.

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

_bap_script_dir=""
bap_script_dir() {
    _bap_script_dir=""

    _bap_filename_check="_prompt.sh"

    # Just in case someone did something stupid like sent in '~' instead of '$HOME'... >.>
    local input_dir="$1"
    if [ ! -d "$input_dir" ]; then
        echo "Not a directory?: $input_dir"
        echo "If there's a tilde ('~') in there, use \$HOME maybe."
        echo "Need dir of '${_bap_filename_check}' for \`bap\` setup."
        return 1
    fi

    if [ ! -f "${input_dir}/${_bap_filename_check}" ]; then
        echo "Don't see \`bap\` source here..."
        echo "No '${input_dir}/${_bap_filename_check}' file?"
        return 1
    fi

    _bap_script_dir="$input_dir"
    return 0
}


# https://unix.stackexchange.com/a/207214
bap_pretty_pwd() {
    # `$PWD` doesn't use "~" shortcut for "/home/<user>/" this is to stuff that back in.
    # This works for Bash.
    dirs +0
    # This is the ZSH version:
    #   dirs -c
    #   dirs
    return $?
}


bap_pretty_path() {
    local dir="$1"
    cd "$dir"
    bap_pretty_pwd
}


# `realpath` will complain if you give it a "~/..." directory path?
# Example:
#   > $ realpath --relative-to="~/repositories/" "~/repositories/foobar"
#   > realpath: '~/repositories/': No such file or directory
# So... first use `realpath` to expand the paths.
bap_pretty_path_relative() {
    local root="$(realpath $1)"
    local dir="$(realpath $2)"
    realpath --relative-to="$root" "$dir"
}
