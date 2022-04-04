# ╔══════════════════════════════════════════════════════════════════════════╗ #
# ║                        bap - Bourne Again Prompt                         ║ #
# ╠══════════════════════════════════════════════════════════════════════════╣ #
# ║ A Bash Prompt that uses Functions and Variables, and can be understood?* ║ #
# ║                                    :o                                    ║ #
# ╚══════════════════════════════════════════════════════════════════════════╝ #
# *Understanding not guarenteed.


# ------------------------------------------------------------------------------
# Settings for the End User
# ------------------------------------------------------------------------------

declare -i bap_ps1_max_width=80

bap_prev_cmd_exit_quote_left="「"
bap_prev_cmd_exit_quote_right="」"
# Those are 2 chars wide:
bap_prev_cmd_exit_quote_left_eqiv="--"
bap_prev_cmd_exit_quote_right_eqiv="--"

# bap_ps1_entry_prompt="\$> "
bap_ps1_entry_prompt="❯ "
bap_ps2_entry_prompt="$bap_ps1_entry_prompt"


bap_show_ip=true


# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

declare bap_prev_cmd_exit_status=""
export bap_prev_cmd_exit_status

# Was the previous prompt a command that was run, or a Ctrl-C, empty prompt, etc?
_bap_cmd_ran=false


# ------------------------------------------------------------------------------
# ==============================================================================
#                                -- Function --
# ==============================================================================
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

bap_cmd_ran() {
  local -i timer_pid=$1

  if $_bap_cmd_ran ; then
    return 0
  fi

  if bap_timer_valid $timer_pid; then
    return 0
  fi

  return 1
}


bap_cmd_errored() {
  local -i timer_pid=$1

  # Command can only error if it ran.
  if bap_cmd_ran $_bap_timer_pid ; then
    test ! -z "$bap_prev_cmd_exit_status"
    return $?
  fi

  # Command did not error.
  return 1
}

# ------------------------------------------------------------------------------
# Import Functions and such.
# ------------------------------------------------------------------------------

bap_import() {
  local import_path="$1"
  source "$import_path/_path.sh"

  # ---
  # Make sure we know where we are.
  # ---
  if ! bap_script_dir "$1"; then
    return $?
  fi

  # ------------------------------
  # PS1 Command Prompt Stuff.
  # ------------------------------

  # ---
  # Colors: De-uglifying Color Codes
  # ---
  source "${_bap_script_dir}/_ansi_codes.sh"
  bap_ansi_setup "$_bap_script_dir"

  source "${_bap_script_dir}/_print.sh"
  if ! bap_print_setup "$_bap_script_dir"; then
    return $?
  fi

  # ---
  # OS
  # ---
  source "${_bap_script_dir}/_os.sh"
  bap_os_setup "$_bap_script_dir"

  source "${_bap_script_dir}/_timer.sh"
  bap_timer_setup "$_bap_script_dir"

  # ---
  # About Me & Environment
  # ---
  source "${_bap_script_dir}/_usr_env.sh"
  bap_usr_env_setup "$_bap_script_dir" $bap_show_ip

  # ---
  # Version Control
  # ---
  source "${_bap_script_dir}/_vc.sh"
  bap_vc_setup "$_bap_script_dir"
}


# ------------------------------
# PS0: Runs right /before/ the command is executed.
# ------------------------------

bap_output_ps0() {
  bap_timer_start $_bap_timer_pid

  _bap_cmd_ran=true
}


bap_setup_ps0() {
  PS0='$(bap_output_ps0)'
}


# ------------------------------------------------------------------------------
# PS1: The Main Prompt.
# ------------------------------------------------------------------------------

# NOTE: Oddity with Bash Escape Sequences and Numbers:
#   Because we want the time right after an escape sequence, the leading digit
#   tends to get stripped for some fun reason if we just build the string like:
#     x="${y}${z}..."
#   So... echo the string in pieces, evaluating the escape codes as we go...

bap_output_ps1_footer() {
  local ps1_entry_raw=""

  # ------------------------------
  # Line -1: Blank line to separate out teh actual command a bit.
  # ------------------------------
  bap_print_newline

  # ------------------------------
  # Line 00: Footer
  # ------------------------------
    # Left corner of the line...
  ps1_entry_raw="╘"
  local -i width_curr=${#ps1_entry_raw}
  bap_print_ps1 "${_bap_print_text_props}${ps1_entry_raw}"

  # ---
  # Error Code
  # ---
  # `bap_prev_cmd_exit_status` is set in ~bap_prompt_command~.
  # Display it in the prompt if it's not empty string.
  #   - However, do not display it if the timer is invalid. Invalid timer
  #     suggests the error exit code was from a while ago and thus stale.
  if bap_cmd_errored $_bap_timer_pid; then
    # Print error code & spacer.
    ps1_entry_raw="${bap_prev_cmd_exit_quote_left_eqiv}${bap_prev_cmd_exit_status}${bap_prev_cmd_exit_quote_right_eqiv}═"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    bap_print_ps1 "${bap_ps1_ansi_reset}${bap_ps1_ansi_red}"
    bap_print_ps1 "${bap_prev_cmd_exit_quote_left}${bap_prev_cmd_exit_status}${bap_prev_cmd_exit_quote_right}"
    bap_print_ps1 "${bap_ps1_ansi_reset}${_bap_print_text_props}═"
  fi

  # ---
  # Command Timer
  # ---
  # TODO: Maybe nicer format for longer durations? "⧗hh:mm:ss.mmm"
  #   - Currently just "s.mmm"
  bap_timer_stop $_bap_timer_pid
  if [[ ! -z "$_bap_timer_duration" ]]; then
    # Print timer.
    ps1_entry_raw="⧗${_bap_timer_duration}"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    bap_print_ps1 "⧗${_bap_print_text_props_reset}${bap_ps1_ansi_green}"
    bap_print_ps1 "${_bap_timer_duration}"

    # Print spacer.
    ps1_entry_raw="═"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))
    bap_print_ps1 "${bap_ps1_ansi_reset}${_bap_print_text_props}${ps1_entry_raw}"
  fi

  # ---
  # MIDDLE FILL SHOULD GO HERE!!!
  # ---
  # But first we need to figure out how wide the left-hand side stuff is...

  # ---
  # Date & Time : Part 01
  # ---
  # Figure out width so we can make fill.
  bap_env_timestamp
  # Including the ending corner.
  ps1_entry_raw="◷[${_bap_env_timestamp}]╛"
  width_curr=$(($width_curr + ${#ps1_entry_raw}))

  # ---
  # MIDDLE FILL DOES GO HERE!!!
  # ---
  bap_terminal_width $bap_ps1_max_width
  bap_print_fill $(($_bap_terminal_width - $width_curr)) ═

  # ---
  # Date & Time : Part 02
  # ---
  # Actually print it (w/ ending corner).
  bap_print_ps1 "◷[${_bap_print_text_props_reset}${bap_ps1_ansi_green}"
  bap_print_ps1 "${_bap_env_timestamp}"
  bap_print_ps1 "${bap_ps1_ansi_reset}${_bap_print_text_props}]╛\n"
}


bap_output_ps1_interim() {
  bap_print_centered $bap_ps1_max_width "╶─╼━╾─╴"
}


bap_output_ps1_header() {
  # ---
  # Left corner of the line...
  # ---
  local ps1_entry_raw="╒"
  local -i width_curr=${#ps1_entry_raw}
  bap_print_ps1 "${_bap_print_text_props}${ps1_entry_raw}"

  # ---
  # OS info.
  # ---
  if [[ ! -z "$bap_ps1_os" ]]; then
    ps1_entry_raw=" ${bap_ps1_os} ═"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    bap_print_ps1 "${ps1_entry_raw}"
  fi

  # ---
  # Optional CHROOT info.
  # ---
  if [[ ! -z "${bap_ps1_chroot}" ]]; then
    ps1_entry_raw="${bap_ps1_chroot} ="
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    bap_print_ps1 "${ps1_entry_raw}"
  fi

  # ---
  # User info.
  # ---
  bap_env_ident
  if [[ ! -z "${_bap_env_ident}" ]]; then
    ps1_entry_raw=" ${_bap_env_ident} "
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    bap_print_ps1 " ${_bap_print_text_props_reset}"
    bap_print_ps1 "${bap_ps1_ansi_green}${_bap_env_ident}${bap_ps1_ansi_reset}"
    bap_print_ps1 " ${_bap_print_text_props}"
  fi

  # ---
  # MIDDLE FILL SHOULD GO HERE!!!
  # ---
  # But first we need to figure out how wide the left-hand side stuff is...

  # ---
  # Left-Hand Side Stuff.
  # ---
  if $bap_show_ip ; then
    ps1_entry_raw=" ${_bap_env_ip_addr_private} ╱ ${_bap_env_ip_addr_public} "
    width_curr=$(($width_curr + ${#ps1_entry_raw}))
  fi

  ps1_entry_raw="╕"
  width_curr=$(($width_curr + ${#ps1_entry_raw}))

  # ---
  # MIDDLE FILL DOES GO HERE!!!
  # ---
  bap_terminal_width $bap_ps1_max_width
  bap_print_fill $(($_bap_terminal_width - $width_curr)) ═

  # ---
  # IP Address.
  # ---

  if $bap_show_ip ; then
    # Let it still be dim?
    # Then have to add print props back in after reset to keep it dim.
    bap_print_ps1 " ${bap_ps1_ansi_green}"
    bap_print_ps1 "${_bap_env_ip_addr_private}"
    bap_print_ps1 "${bap_ps1_ansi_reset}${_bap_print_text_props} ╱ ${bap_ps1_ansi_blue}"
    bap_print_ps1 "${_bap_env_ip_addr_public}"
    bap_print_ps1 "${bap_ps1_ansi_reset}${_bap_print_text_props} "
  fi

  # ---
  # Final Corner.
  # ---
  bap_print_ps1 "╕\n"
}


bap_output_ps1_dir() {
  # ------------------------------
  # Are we in a version control repository?
  # ------------------------------
  if bap_path_in_vc "$PWD"; then
    # ---
    # Directory
    # ---
    # Can't use "\w" when we're called every prompt and are explicitly echoing the dir.

    # Split into root, relative if in a VC dir.
    local ps1_path_parent="$(dirname "$_bap_path_root_vc")"
    local ps1_path_repo="$(basename "$_bap_path_root_vc")"
    local ps1_path_rel="$(realpath --relative-to="$_bap_path_root_vc" "$PWD")"

    # Repo's root path one color & relative path a second color.
    bap_print_ps1 "${_bap_print_text_props}├┬ ${_bap_print_text_props_reset}"
    bap_print_ps1 "${bap_ansi_blue}${ps1_path_parent}/"
    # Still blue but also underline the repo name.
    bap_print_ps1 "${bap_ansi_underline}${ps1_path_repo}${bap_ansi_underline_reset}"
    # Recolor "/relative/path/in/repo" to "version control color".
    bap_print_ps1 "${bap_ansi_yellow}/${ps1_path_rel}${bap_ansi_reset}\n"

    # ---
    # Version Control
    # ---
    bap_print_ps1 "${_bap_print_text_props}│└─${_bap_print_text_props_reset}"
    bap_print_ps1 "${bap_ansi_yellow}$(bap_ps1_vc_prompt)${bap_ansi_reset}\n"

  else
    # ---
    # Directory Only
    # ---

    # All one color.
    bap_print_ps1 "${_bap_print_text_props}├─ ${_bap_print_text_props_reset}${bap_ansi_blue}${PWD}${bap_ansi_reset}\n"

  fi
}

bap_output_ps1_prompt() {
  # Final PS1 line: The Prompt.
  bap_print_ps1 "${_bap_print_text_props}└┤${_bap_print_text_props_reset}${bap_ps1_entry_prompt}"
}


bap_output_ps1() {
  # ------------------------------
  # Build & output the prompt:
  # ------------------------------
  # Only output footer/interim if we actually ran a previous command.
  if bap_cmd_ran $_bap_timer_pid; then
    bap_output_ps1_footer
    bap_output_ps1_interim
  fi

  bap_output_ps1_header

  bap_output_ps1_dir

  bap_output_ps1_prompt

  # ------------------------------
  # Clean-Up
  # ------------------------------
  bap_timer_clear $_bap_timer_pid
  _bap_cmd_ran=false
}


bap_setup_ps1() {
  PS1='$(bap_output_ps1)'
}


# ------------------------------------------------------------------------------
# PS2: Used as prompt for incomplete commands.
# ------------------------------------------------------------------------------
bap_output_ps2() {
  # ------------------------------
  # Set up PS2 variable
  # ------------------------------
  # PS1:
  #    "..."
  #    "${_bap_print_text_props}└┤${_bap_print_text_props_reset}$[bap_ps1_entry_prompt}"
  echo -e "${_bap_print_text_props} │${_bap_print_text_props_reset}${bap_ps2_entry_prompt}"
}


bap_setup_ps2() {
  PS2='$(bap_output_ps2)'
}


# ------------------------------------------------------------------------------
# PS3: Used as prompt for ~select~ statements.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# PS4: Prefix for statements during execution trace (~set -x~).
#   - Printed multiple times if multiple levels of indirection.
#   - Default is: "+ "
# ------------------------------------------------------------------------------


# ------------------------------
# Set-Up / Init for Prompts.
# ------------------------------
bap_setup() {
  local dir="$1"
  bap_import "$dir"
  bap_setup_ps0
  bap_setup_ps1
  bap_setup_ps2
}


# ------------------------------------------------------------------------------
# Prompt Builder
# ------------------------------------------------------------------------------

bap_prompt_command() {
  # ------------------------------
  # First: Exit Code
  # ------------------------------
  # This needs to be first in order to get the last command's exit code.
  local -i exit_code=$?

  # ------------------------------
  # Exit Code Status
  # ------------------------------

  if [[ $exit_code -eq 0 ]]; then
    bap_prev_cmd_exit_status=""
  else
    bap_prev_cmd_exit_status="${exit_code}"
  fi

  # bap_prev_cmd="$BASH_COMMAND"
}
