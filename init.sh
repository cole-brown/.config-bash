# Source this file.

bap_path_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# ------------------------------------------------------------------------------
# Run init.
# ------------------------------------------------------------------------------

source "${bap_path_root}/_path.sh"

# ---
# Make sure we know where we are.
# ---
if ! bap_script_dir "$bap_path_root"; then
    return $?
fi

# ---
# Import & set-up all the BAP functionality, in order.
# ---

# Colors: De-uglifying Color Codes
source "${bap_path_root}/_ansi_codes.sh"
bap_ansi_setup "$bap_path_root"

# Output Helpers
source "${bap_path_root}/_print.sh"
if ! bap_print_setup "$bap_path_root"; then
    return $?
fi

# OS Info
source "${bap_path_root}/_os.sh"
bap_os_setup "$bap_path_root"

# Timing Info
source "${bap_path_root}/_timer.sh"
bap_timer_setup "$bap_path_root"

# About Me & Environment
source "${bap_path_root}/_usr_env.sh"
bap_usr_env_setup "$bap_path_root" $( $bap_show_ip_in_header || $bap_show_ip_in_subheader )

# Version Control
source "${bap_path_root}/_vc.sh"
bap_vc_setup "$bap_path_root"

# Set Bash Prompts to `bap` versions.
source "${bap_path_root}/_prompt.sh"
bap_prompt_setup "$bap_path_root"
