# ╔══════════════════════════════════════════════════════════════════════════╗ #
# ║                        bap - Bourne Again Prompt                         ║ #
# ╠══════════════════════════════════════════════════════════════════════════╣ #
# ║                      The File that Does Everything.                      ║ #
# ╚══════════════════════════════════════════════════════════════════════════╝ #


# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

declare -i bap_ps1_max_width=80


# ------------------------------
# PS1: Variables for the PS1.
# ------------------------------

declare bap_prev_cmd_exit_status=""
export bap_prev_cmd_exit_status

bap_prev_cmd_exit_quote_left="「"
bap_prev_cmd_exit_quote_right="」"
# Those are 2 chars wide:
bap_prev_cmd_exit_quote_left_eqiv="--"
bap_prev_cmd_exit_quote_right_eqiv="--"

# bap_ps1_entry_prompt="\$> "
bap_ps1_entry_prompt="❯ "
bap_ps2_entry_prompt="$bap_ps1_entry_prompt"


# ------------------------------------------------------------------------------
# ==============================================================================
#                                -- Function --
# ==============================================================================
# ------------------------------------------------------------------------------

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
  bap_usr_env_setup "$_bap_script_dir"

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

  if [[ ! -z "$bap_prev_cmd_exit_status" ]]; then
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


bap_output_ps1() {
  bap_output_ps1_footer

  # ------------------------------
  # Build the prompt:
  # ------------------------------

  # ---
  # Build Header (OS/CHROOT/USER/...).
  # ---
  # OS info.
  ps1_entry_raw="${bap_ps1_os}"
  ps1_entry_fmt="${bap_ps1_ansi_dim}${bap_ps1_os}${bap_ps1_ansi_dim_reset}"
  # Start with entry and also separator character.
  ps1_line_header_raw=" ${ps1_entry_raw} ═"
  ps1_line_header_fmt=" ${ps1_entry_fmt}${_bap_print_text_props} ═${_bap_print_text_props_reset}"

  # Optional CHROOT info.
  if [[ ! -z "${bap_ps1_chroot}" ]]; then
    ps1_entry_raw="${bap_ps1_chroot}"
    ps1_entry_fmt="${bap_ps1_ansi_dim}${bap_ps1_chroot}${bap_ps1_ansi_dim_reset}"
    # Append entry and also separator character.
    ps1_line_header_raw="${ps1_line_header_raw} ${ps1_entry_raw} ="
    ps1_line_header_fmt="${ps1_line_header_fmt} ${ps1_entry_fmt}${_bap_print_text_props} =${_bap_print_text_props_reset}"
  fi

  # User info.
  bap_env_ident
  ps1_entry_raw="${_bap_env_ident}"
  ps1_entry_fmt="${bap_ps1_ansi_green}${_bap_env_ident}${bap_ps1_ansi_reset}"
  # No separator - this is the last thing.
  ps1_line_header_raw="${ps1_line_header_raw} ${ps1_entry_raw} "
  ps1_line_header_fmt="${ps1_line_header_fmt} ${ps1_entry_fmt} "

  # ------------------------------
  # Output the prompt:
  # ------------------------------

  # ---
  # Intermission
  # ---
  bap_print_centered $bap_ps1_max_width "╶─╼━╾─╴"

  # ---
  # Prompt for this command.
  # ---

  # Line 01: OS, user/host, etc.
  # echo "${ps1_entry_os}:${ps1_entry_chroot}${bap_ps1_user}"
  # bap_print_headline $bap_ps1_max_width ╒ ═ ╕ "${ps1_fmt_line}"
  bap_print_headline $bap_ps1_max_width ╒ ═ ╕ ${#ps1_line_header_raw} "${ps1_line_header_fmt}"

  # Line 02 (+03): Current Dir (+ Version Control Info)
  echo -e "$(bap_output_ps1_dir)"

  # Line 04: Prompt.
  echo -e "${_bap_print_text_props}└┤${_bap_print_text_props_reset}${bap_ps1_entry_prompt}"
}


bap_output_ps1_dir() {
  # ------------------------------
  # Version Control
  # ------------------------------
  local ps1_entry_vc="${bap_ansi_yellow}$(bap_ps1_vc_prompt)${bap_ansi_reset}"

  # ------------------------------
  # Directory
  # ------------------------------
  # Can't use "\w" when we're called every prompt and are explicitly echoing the dir.
  # local ps1_entry_dir=" ${bap_ps1_ansi_blue}${bap_ps1_dir}${bap_ps1_ansi_reset}"

  # ------------------------------
  # Output Dir/VC lines.
  # ------------------------------
  if bap_path_in_vc "$PWD"; then
    #local ps1_path_root="$_bap_path_root_vc"

    # Split into root, relative if in a VC dir.
    local ps1_path_parent="$(dirname "$_bap_path_root_vc")"
    local ps1_path_repo="$(basename "$_bap_path_root_vc")"
    local ps1_path_rel="$(realpath --relative-to="$_bap_path_root_vc" "$PWD")"

    # Repo's root path one color & relative path a second color.
    # Also, underline the repo name.
    echo -e "${_bap_print_text_props}├┬ ${_bap_print_text_props_reset}${bap_ansi_blue}${ps1_path_parent}/${bap_ansi_underline}${ps1_path_repo}${bap_ansi_underline_reset}${bap_ansi_yellow}/${ps1_path_rel}${bap_ansi_reset}"
    echo -e "${_bap_print_text_props}│└─${_bap_print_text_props_reset}${ps1_entry_vc}"
  else
    # All one color.
    echo -e "${_bap_print_text_props}├─ ${_bap_print_text_props_reset}${bap_ansi_blue}${PWD}${bap_ansi_reset}"
  fi

  # ------------------------------
  # Clean-Up
  # ------------------------------
  bap_timer_clear $_bap_timer_pid
}


bap_setup_ps1() {
  # TODO: Have to put all the
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
