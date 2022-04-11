# Source this file.


# ------------------------------------------------------------------------------
# Variables: Text Properties
# ------------------------------------------------------------------------------

dc_props_dim="\e[2m" # dim
dc_props_dim_reset="\e[22m" # reset dim specifically

# These should be in "_secret.sh", and should set $dc_props_tier if desired.
# dc_props_dev="\e[0;32m"
# dc_props_stg="\e[0;33m"
# dc_props_prd="\e[0;31m"

# This should be defined in "_secret.sh" if different color for tier is desired.
# dc_props_tier="..."

dc_props_reset="\e[0m"

dc_max_width=80

# Just a big buffer of spaces to trim down to what we want.
dc_padding_spaces="$(printf '%0.1s' ' '{1..200})"


# ------------------------------------------------------------------------------
# Functions: Pretty Priting
# ------------------------------------------------------------------------------

_dc_terminal_width=-1
dc_terminal_width() {
    local -i width=$(tput cols)
    local -i returncode=$?
    if [[ -n "$1" ]]; then
        local -i max=$1
        _dc_terminal_width=$(( $width > $max ? $max : $width ))
    else
        _dc_terminal_width=$width
    fi
    return $returncode
}


dc_print_centered () {
    local -i width=$1
    local -i string_width=$2
    shift 2
    local string="$@"

    # Get actual width to use:
    dc_terminal_width $width
    width=$_dc_terminal_width

    # The left side will be the short side if needed.
    local -i pad_left=$(( ($width - $string_width) / 2 ))
    # # The extra will be on the right side if needed.
    # local -i pad_right=$(( ($width + 1 - $string_width) / 2 ))

    # '%*.*s' = Spaces for the left padding based on string size.
    # '%s'    = The string.
    printf "%*.*s%s\n" 0 "$pad_left" "$dc_padding_spaces" "$(echo -ne $string)"
}


# ------------------------------------------------------------------------------
# Message of the Day / Login Banner
# ------------------------------------------------------------------------------

echo
dc_string="╶─╼━━━╾─╴"
dc_print_centered $dc_max_width ${#dc_string} "${dc_props_dim}${dc_string}${dc_props_dim_reset}"

if [[ -n "$dc_title" ]]; then
    dc_string="$dc_title"
    dc_print_centered $dc_max_width ${#dc_string} "${dc_string}"

    # Start tier echo w/ separator.
    echo -ne "$dc_props_tier"
    dc_string="╶─╼━╾─╴"
    dc_print_centered $dc_max_width ${#dc_string} "${dc_props_dim}${dc_string}${dc_props_dim_reset}"
else
    # Start tier echo w/o separator.
    echo -ne "$dc_props_tier"
fi

dc_string="$dc_tier_long"
dc_print_centered $dc_max_width ${#dc_string} "${dc_string}"

dc_string="╶─╼━╾─╴"
dc_print_centered $dc_max_width ${#dc_string} "${dc_props_dim}${dc_string}${dc_props_dim_reset}"
echo -ne "$dc_props_reset" # Clear out tier coloring

dc_string="${dc_profile}"
dc_print_centered $dc_max_width ${#dc_string} "${dc_string}"

dc_string="${dc_ip_addr}"
dc_print_centered $dc_max_width ${#dc_string} "${dc_string}"

dc_string="╶─╼━━━╾─╴"
dc_print_centered $dc_max_width ${#dc_string} "${dc_props_dim}${dc_string}"

echo -ne "$dc_props_reset"
