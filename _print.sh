# Source this.

# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

# ------------------------------
# Misc
# ------------------------------

# Just a big buffer of spaces to trim down to what we want.
bap_padding_spaces="$(printf '%0.1s' ' '{1..200})"

# 0 == false, 1 == true
declare -i bap_lines_dim=1


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


_bap_print_text_props=""
_bap_print_text_props_reset=""
bap_print_text_props() {
    _bap_print_text_props=""
    _bap_print_text_props_reset=""

    if (( bap_lines_dim != 0 )); then
        _bap_print_text_props="${bap_ansi_dim}"
        _bap_print_text_props_reset="${bap_ansi_dim_reset}"
    fi
}


# ------------------------------------------------------------------------------
# Printing / Output
# ------------------------------------------------------------------------------

bap_print_headline() {
    # Inputs:
    local -i width=$1
    local corner_left="$2"
    local fill_char="$3"
    local corner_right="$4"
    # I don't know how to strip out the "\[" and "\]" that the PS1 uses...
    # so passing in explicit length for now.
    local -i msg_length=$5

    shift 5

    # The rest of the params are the message.
    local msg="$@"

    # Get actual width to use:
    bap_terminal_width $width
    width=$_bap_terminal_width

    # Create long fill string we can grab a substring of for final line.
    local -i width_too_long=$((width + 10))
    fill_too_long="$(printf "%*s" $width_too_long $fill_char)"
    # Then replace all the spaces with the line char for complete line.
    fill_too_long=$(echo "${fill_too_long// /$fill_char}")

    # Get width of fill.
    local -i fill_width=$(( $width - ${#corner_left} - ${#corner_right} - ${msg_length} ))

    # Piece together line & print:
    local left="${_bap_print_text_props}${corner_left}${_bap_print_text_props_reset}"
    local fill="${_bap_print_text_props}${fill_too_long:1:$fill_width}"
    local right="${corner_right}${_bap_print_text_props_reset}"

    echo "${left}${msg}${fill}${right}"

    # If you need to debug what's going on, ~printf~ with "%q" is helpful:
    #   printf "foot raw: '%q'\n" "$ps1_line_footer_raw"
    #   printf "foot fmt: '%q'\n" "$ps1_line_footer_fmt"
}


# NOTE: This cannot handle the PS1 variables like '\u', etc. They're not
# expanded yet so the calculated message string length will be incorrect.
#   See: https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
bap_print_headline_auto() {
    # Inputs:
    local -i width=$1
    local corner_left="$2"
    local fill_char="$3"
    local corner_right="$4"
    shift 4

    # The rest of the params are the message.
    local msg="$@"

    # Strip ANSI escape sequences so we can get a count of the actual characters.
    bap_ansi_strip "$msg"

    # Print line w/ stripped msg length.
    bap_print_headline $width "$corner_left" "$fill_char" "$corner_right" ${#_bap_ansi_strip} "$msg"
}


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

    bap_print_text_props
    return 0
}
