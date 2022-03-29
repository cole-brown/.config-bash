# Source this.

declare -i _terminal_width=-1
terminal_width() {
    local -i width=$(tput cols)
    local -i returncode=$?
    if [[ ! -z "$1" ]]; then
        local -i max=$1
        _terminal_width=$(( $width > $max ? $max : $width ))
    else
        _terminal_width=$width
    fi
    return $returncode
}


declare -i _terminal_height=-1
terminal_height() {
    local -i height=$(tput lines)
    local -i returncode=$?
    if [[ ! -z "$1" ]]; then
        local -i max=$1
        _terminal_height=$(( $height > $max ? $max : $height ))
    else
        _terminal_height=$height
    fi
    return $returncode
}


_ps1_print_line() {
    # Inputs:
    local -i width=$1
    local corner_left="$2"
    local fill_char="$3"
    local corner_right="$4"
    shift 4
    # The rest is the message on the line.
    local msg="$@"

    # Get actual width to use:
    terminal_width $width
    width=$_terminal_width
    msg_no_escapes="${msg//\\/}" # Delete all backslashes.
    # Get width of fill.
    local -i fill_width=$(( $width - ${#corner_left} - ${#corner_right} - ${#msg} ))

    # Create fill:
    local fill_line="$(printf "%*s" $fill_width $fill_char)"
    # Then replace all the spaces with the line char for complete line.
    fill_line=$(echo "${fill_line// /$fill_char}")

    # Piece together line & print:
    echo "${corner_left}${msg}${fill_line}${corner_right}"
}
