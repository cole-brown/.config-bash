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
bap_setting_text_weak_dim=${bap_setting_text_weak_dim:-true} # false / true
bap_setting_text_weak_color="${bap_setting_text_weak_color:-}" # $bap_text_fmt_[color]


# ---
# All Together: "Weak Text"
# ---
# "Weak" because it's supposed to be "background" / "pretty" / etc text for
# ASCII box art, alignment, etc.
#
# `bap_setting_text_weak_dim` et al as PS1/ANSI escape sequences.

# Just properties like dim/underline.
bap_text_weak_props="${bap_text_weak_props:-}"

# Properties and colors.
bap_text_weak_full="${bap_text_weak_full:-}"

# AKA bap_text_fmt_reset.
bap_text_weak_reset="${bap_text_weak_reset:-}" # Reset all colors/formatting.


# ------------------------------
# Misc
# ------------------------------

# Just a big buffer of spaces to trim down to what we want.
bap_text_padding_spaces="$(printf '%0.1s' ' '{1..200})"


# ------------------------------------------------------------------------------
# Formatting & Coloring Sequences
# ------------------------------------------------------------------------------

# TODO: Split into smaller functions or leave as a big single?
#   - Make a function for generating codes instead of creating all these variables?

# TODO: More format codes:
#   - https://misc.flogisoft.com/bash/tip_colors_and_formatting
#     - Left off at "8/16 Colors"

# ------------------------------
# ANSI Codes
# ------------------------------

# ---
# General
# ---
# These are all just the escape key, basically.
# _bap_ansi_escape_oct="\033" # octal 33
# _bap_ansi_escape_hex="\x1b" # hex   1b
_bap_ansi_escape="\e"

_bap_ansi_reset="${_bap_ansi_escape}[0m"

# ---
# Colors
# ---
_bap_ansi_red="${_bap_ansi_escape}[0;31m"
_bap_ansi_green="${_bap_ansi_escape}[01;32m"
_bap_ansi_yellow="${_bap_ansi_escape}[0;33m"
_bap_ansi_blue="${_bap_ansi_escape}[01;34m"
_bap_ansi_purple="${_bap_ansi_escape}[0;35m" # aka magenta?
_bap_ansi_teal="${_bap_ansi_escape}[0;36m"

# Inverts foreground and background colors.
# AKA "reverse"
_bap_ansi_invert="${_bap_ansi_escape}[7m"

# ---
# Text Properties
# ---
_bap_ansi_bold="${_bap_ansi_escape}[1m"
_bap_ansi_dim="${_bap_ansi_escape}[2m"
_bap_ansi_italic="${_bap_ansi_escape}[3m"
_bap_ansi_underline="${_bap_ansi_escape}[4m"
_bap_ansi_blink="${_bap_ansi_escape}[5m"
_bap_ansi_hidden="${_bap_ansi_escape}[8m" # For e.g. passwords.
_bap_ansi_strikethrough="${_bap_ansi_escape}[9m"

_bap_ansi_bold_reset="${_bap_ansi_escape}[21m"
_bap_ansi_dim_reset="${_bap_ansi_escape}[22m"
_bap_ansi_italic_reset="${_bap_ansi_escape}[23m"
_bap_ansi_underline_reset="${_bap_ansi_escape}[24m"
_bap_ansi_blink_reset="${_bap_ansi_escape}[25m"
_bap_ansi_hidden_reset="${_bap_ansi_escape}[28m"
_bap_ansi_strikethrough_reset="${_bap_ansi_escape}[29m"

# ------------------------------
# PS1 Codes
# ------------------------------
# "\[" + ANSI Code + "\]"
# The escaped brackets help Bash count how long the prompt actually is or
# something. Can't use "\[" and "\]" because they just show up as-is, but the
# equivalent "\001" and \"002" work fine.*
# bap_text_fmt_escape_start="\["
# bap_text_fmt_escape_end="\]"
bap_text_fmt_escape_start="\001"
bap_text_fmt_escape_end="\002"
# *They work fine until you try displaying a number right after one...
# "\002" + "0.3" = "\0020.3" --> ".3" (the 0 gets eaten by the "\002" escape sequence).

# ---
# General
# ---
bap_text_fmt_reset="${bap_text_fmt_escape_start}${_bap_ansi_reset}${bap_text_fmt_escape_end}"

# ---
# Colors
# ---
bap_text_fmt_red="${bap_text_fmt_escape_start}${_bap_ansi_red}${bap_text_fmt_escape_end}"
bap_text_fmt_green="${bap_text_fmt_escape_start}${_bap_ansi_green}${bap_text_fmt_escape_end}"
bap_text_fmt_yellow="${bap_text_fmt_escape_start}${_bap_ansi_yellow}${bap_text_fmt_escape_end}"
bap_text_fmt_blue="${bap_text_fmt_escape_start}${_bap_ansi_blue}${bap_text_fmt_escape_end}"
bap_text_fmt_purple="${bap_text_fmt_escape_start}${_bap_ansi_purple}${bap_text_fmt_escape_end}"
bap_text_fmt_teal="${bap_text_fmt_escape_start}${_bap_ansi_teal}${bap_text_fmt_escape_end}"

bap_text_fmt_invert="${bap_text_fmt_escape_start}${_bap_ansi_invert}${bap_text_fmt_escape_end}"

# ---
# Text Properties
# ---
bap_text_fmt_bold="${bap_text_fmt_escape_start}${_bap_ansi_bold}${bap_text_fmt_escape_end}"
bap_text_fmt_dim="${bap_text_fmt_escape_start}${_bap_ansi_dim}${bap_text_fmt_escape_end}"
bap_text_fmt_italic="${bap_text_fmt_escape_start}${_bap_ansi_italic}${bap_text_fmt_escape_end}"
bap_text_fmt_underline="${bap_text_fmt_escape_start}${_bap_ansi_underline}${bap_text_fmt_escape_end}"
bap_text_fmt_blink="${bap_text_fmt_escape_start}${_bap_ansi_blink}${bap_text_fmt_escape_end}"
bap_text_fmt_hidden="${bap_text_fmt_escape_start}${_bap_ansi_hidden}${bap_text_fmt_escape_end}"
bap_text_fmt_strikethrough="${bap_text_fmt_escape_start}${_bap_ansi_strikethrough}${bap_text_fmt_escape_end}"

bap_text_fmt_bold_reset="${bap_text_fmt_escape_start}${_bap_ansi_bold_reset}${bap_text_fmt_escape_end}"
bap_text_fmt_dim_reset="${bap_text_fmt_escape_start}${_bap_ansi_dim_reset}${bap_text_fmt_escape_end}"
bap_text_fmt_italic_reset="${bap_text_fmt_escape_start}${_bap_ansi_italic_reset}${bap_text_fmt_escape_end}"
bap_text_fmt_underline_reset="${bap_text_fmt_escape_start}${_bap_ansi_underline_reset}${bap_text_fmt_escape_end}"
bap_text_fmt_blink_reset="${bap_text_fmt_escape_start}${_bap_ansi_blink_reset}${bap_text_fmt_escape_end}"
bap_text_fmt_hidden_reset="${bap_text_fmt_escape_start}${_bap_ansi_hidden_reset}${bap_text_fmt_escape_end}"
bap_text_fmt_strikethrough_reset="${bap_text_fmt_escape_start}${_bap_ansi_strikethrough_reset}${bap_text_fmt_escape_end}"


# ------------------------------------------------------------------------------
# Formatting / Coloring Functions
# ------------------------------------------------------------------------------

# TODO: Does this strip the \001 & \002 sequences?
# TODO: Either:
# TODO:   1) Delete this? Not using?
# TODO:   2) Rename to `bap_text_fmt_strip`?
#
# Strip ANSI (and PS1) escape sequences from input string.
_bap_ansi_strip=""
bap_ansi_strip() {
    _bap_ansi_strip=""
    local string="$@"

    # No input == error.
    if [[ -z "$string" ]]; then
        return 1
    fi

    # Using [a-zA-Z], which is all escape sequences.
    #
    # If you want to restrict to just certain escape sequences:
    # ----------------------------------------------
    # Last escape sequence...
    #   Character   Purpose
    #   ---------   -------------------------------
    #   m           Graphics Rendition Mode (including Color)
    #   G           Horizontal cursor move
    #   K           Horizontal deletion
    #   H           New cursor position
    #   F           Move cursor to previous n lines

    # https://superuser.com/a/380778
    #
    # Search for ANSI escape sequences, replace with nothing.
    _bap_ansi_strip="$(echo -e "$string" | sed 's/\\[?\x1B\[[0-9;]*[a-zA-Z]//g')"
    return $?
}


# ------------------------------------------------------------------------------
# Terminal Info
# ------------------------------------------------------------------------------
# TODO: move to _terminal.sh?

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

bap_text_out_newline() {
    echo
}


bap_text_out() {
    echo -ne "${@}"
}


bap_text_out_fill () {
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
    bap_text_out "${fill_str:0:$width}"
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
bap_text_out_centered () {
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
    printf "%*.*s%s\n" 0 "$pad_left" "$bap_text_padding_spaces" "$string"

    # # 3) '%*.*s' = Spaces for the right padding based on string size.
    # # NOTE: 1 & 3 can be different because integer math and centering inexactly
    # #   (e.g. centering a 1 char string to 4 width).
    # printf '%*.*s%s%*.*s\n' 0 "$pad_left" "$bap_text_padding_spaces" "$string" 0 "$pad_right" "$bap_text_padding_spaces"
}


# ------------------------------------------------------------------------------
# Set-Up
# ------------------------------------------------------------------------------

bap_text_setup() {
    bap_text_weak_props=""
    bap_text_weak_full=""
    bap_text_weak_reset="$bap_text_fmt_reset"

    # set optional color to provided color code.
    if [[ ! -z "$bap_setting_text_weak_color" ]]; then
        bap_text_weak_full="${bap_text_weak_full}${bap_setting_text_weak_color}"
    fi

    # Set dim after setting color or else color won't be dim...
    if $bap_setting_text_weak_dim; then
        bap_text_weak_props="${bap_text_weak_props}${bap_text_fmt_dim}"
        bap_text_weak_full="${bap_text_weak_full}${bap_text_fmt_dim}"
    fi

    return 0
}
