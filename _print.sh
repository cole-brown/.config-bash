# Source this.

# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

# ------------------------------
# Text Properties for the Pretty Printing background stuff.
# ------------------------------
# 0 == false, 1 == true

# ASCII box art lines should be dimmed?
declare -i bap_lines_dim=1


# ---
# All Together:
# ---
# `bap_lines_dim` et al as PS1/ANSI escape sequences.
_bap_print_text_props=""
_bap_print_text_props_reset=""


# ------------------------------
# Misc
# ------------------------------

# Just a big buffer of spaces to trim down to what we want.
bap_padding_spaces="$(printf '%0.1s' ' '{1..200})"


# ------------------------------------------------------------------------------
# Terminal Info
# ------------------------------------------------------------------------------

declare -i _bap_terminal_width=-1
bap_terminal_width() {
    local -i width=$(tput cols)
    local -i returncode=$?
    if [[ ! -z "$1" ]]; then
        local -i max=$1
        _bap_terminal_width=$(( $width > $max ? $max : $width ))
    else
        _bap_terminal_width=$width
    fi
    return $returncode
}


declare -i _bap_terminal_height=-1
bap_terminal_height() {
    local -i height=$(tput lines)
    local -i returncode=$?
    if [[ ! -z "$1" ]]; then
        local -i max=$1
        _bap_terminal_height=$(( $height > $max ? $max : $height ))
    else
        _bap_terminal_height=$height
    fi
    return $returncode
}


# ------------------------------------------------------------------------------
# Printing / Output : Basic
# ------------------------------------------------------------------------------

bap_print_newline() {
    echo
}


bap_print_ps1() {
    echo -ne "${@}"
}


bap_print_fill () {
    local -i width=$1
    local fill_char="$2"
    if [[ ${#fill_char} -ne 1 ]]; then
        return 1
    fi

    # Minimum width of 1.
    if [[ $width -lt 1 ]]; then
        width=1
    fi

    # ------------------------------
    # Create a fill string.
    # ------------------------------
    # For some reason, trying to create the proper length to start with leaves
    # us 2 characters short? So create something long and then trim down...
    local fill_str="$(printf "%*s" $((width + 10)) $fill_char)"

    echo "bpf"
    echo "  width: $width"
    echo "  f.str: $fill_str"

    # Replace all the spaces with the line char for complete line.
    fill_str=$(echo "${fill_str// /$fill_char}")
    echo "  f.str: $fill_str"

    # Trim down to correct size for print.
    bap_print_ps1 "${fill_str:0:$width}"
}


# ------------------------------------------------------------------------------
# Printing / Output : Alignment
# ------------------------------------------------------------------------------

# $1 = width: will use the min of this width or terminal width to determine center point.
# $2+ = string to print
#
# NOTE: Can be slightly off center (to the left) because odds vs evens and integer math.
#   Examples centered on 10 width:
#     '    x     '
#     '    xx    '
#     '   xxx    '
#     '   xxxx   '
bap_print_centered () {
    local -i width=$1
    shift
    local string="$@"
    local string_width=${#string}

    # Get actual width to use:
    bap_terminal_width $width
    width=$_bap_terminal_width

    # The left side will be the short side if needed.
    local -i pad_left=$(( ($width - $string_width) / 2 ))
    # # The extra will be on the right side if needed.
    # local -i pad_right=$(( ($width + 1 - $string_width) / 2 ))

    # 1) '%*.*s' = Spaces for the left padding based on string size.
    # 2) '%s'    = The (centered) string.
    printf "${_bap_print_text_props}%*.*s%s\n" 0 "$pad_left" "$bap_padding_spaces" "$string"

    # # 3) '%*.*s' = Spaces for the right padding based on string size.
    # # NOTE: 1 & 3 can be different because integer math and centering inexactly
    # #   (e.g. centering a 1 char string to 4 width).
    # printf '%*.*s%s%*.*s\n' 0 "$pad_left" "$bap_padding_spaces" "$string" 0 "$pad_right" "$bap_padding_spaces"
}


# ------------------------------------------------------------------------------
# Set-Up
# ------------------------------------------------------------------------------

bap_print_setup() {
    # Need ANSI codes.
    if [[ -z "${bap_ansi_dim}" ]]; then
        echo "Can't find \`bap\`s ANSI codes..."
        return 1
    fi

    _bap_print_text_props=""
    _bap_print_text_props_reset=""

    # Set our text properties.
    if (( bap_lines_dim != 0 )); then
        _bap_print_text_props="${bap_ps1_ansi_dim}"
        _bap_print_text_props_reset="${bap_ps1_ansi_dim_reset}"
    fi

    return 0
}
