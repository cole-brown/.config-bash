# Source this.

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

_bap_script_dir=""
bap_script_dir() {
    _bap_script_dir=""

    # Just in case someone did something stupid like sent in '~' instead of '$HOME'... >.>
    local input_dir="$1"
    if [ ! -d "$input_dir" ]; then
        echo "Not a directory?: $input_dir"
        echo "If there's a tilde ('~') in there, use \$HOME maybe."
        echo "Need dir of ps1.sh for \`bap\` setup."
        return 1
    fi

    if [ ! -f "${input_dir}/ps1.sh" ]; then
        echo "Don't see \`bap\` source here..."
        echo "No '${input_dir}/ps1.sh' file?"
        return 1
    fi

    _bap_script_dir="$input_dir"
    return 0
}
