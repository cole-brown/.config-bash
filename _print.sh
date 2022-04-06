# Source this.

# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

# ------------------------------
# Text Properties for the Pretty Printing background stuff.
# ------------------------------

# ---
# Variables to Adjust Externally:
# ---
bap_setting_text_weak_dim=true # false / true
bap_setting_text_weak_color="" # $bap_ps1_ansi_[color]


# ---
# All Together: "Weak Text"
# ---
# "Weak" because it's supposed to be "background" / "pretty" / etc text for
# ASCII box art, alignment, etc.
#
# `bap_setting_text_weak_dim` et al as PS1/ANSI escape sequences.

# Just properties like dim/underline.
bap_text_weak_props=""

# Properties and colors.
bap_text_weak_full=""

# AKA bap_ps1_ansi_reset.
bap_text_weak_reset="\e[0m" # Reset all colors/formatting.


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

    # Replace all the spaces with the line char for complete line.
    fill_str=$(echo "${fill_str// /$fill_char}")

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
    printf "${bap_text_weak_props}%*.*s%s\n" 0 "$pad_left" "$bap_padding_spaces" "$string"

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

    bap_text_weak_props=""
    bap_text_weak_full=""

    # Set our text properties.
    if $bap_setting_text_weak_dim; then
        bap_text_weak_props="${bap_text_weak_props}${bap_ps1_ansi_dim}"
        bap_text_weak_full="${bap_text_weak_full}${bap_ps1_ansi_dim}"
    fi

    # Set optional color to provided color code.
    if [[ ! -z "$bap_setting_text_weak_color" ]]; then
        bap_text_weak_full="${bap_text_weak_full}${bap_setting_text_weak_color}"
    fi

    return 0
}
