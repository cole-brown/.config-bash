# ╔══════════════════════════════════════════════════════════════════════════╗ #
# ║                        bap - Bourne Again Prompt                         ║ #
# ╠══════════════════════════════════════════════════════════════════════════╣ #
# ║                      The File that Does Everything.                      ║ #
# ╚══════════════════════════════════════════════════════════════════════════╝ #


# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

declare -i bap_ps1_max_width=80


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

  # ---
  # OS
  # ---
  source "${_bap_script_dir}/_os.sh"
  bap_os_setup "$_bap_script_dir"

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
# PS1: Variables for ~prompt_command~ to fill for PS1.
# ------------------------------

declare bap_prev_cmd_exit_status=""
export bap_prev_cmd_exit_status

# bap_ps1_entry_prompt="\$> "
bap_ps1_entry_prompt="❯ "
bap_ps2_entry_prompt="$bap_ps1_entry_prompt"


# ------------------------------
# PS1: The Main Prompt.
# ------------------------------
bap_output_ps1() {

  # ------------------------------
  # Build the prompt:
  # ------------------------------

  # ---
  # Build Footer (exit code/timestamp/...).
  # ---
  # `bap_prev_cmd_exit_status` Will be set in ~prompt_command~
  local ps1_entry_raw='${bap_prev_cmd_exit_status}'
  local ps1_entry_fmt="${bap_ps1_ansi_red}"'${bap_prev_cmd_exit_status}'"${bap_ps1_ansi_reset}"

  local ps1_line_footer_raw=""
  local ps1_line_footer_fmt=""
  if [[ ! -z "$ps1_line_footer_raw" ]]; then
    ps1_line_footer_raw="${ps1_entry_raw} ═ "
    ps1_line_footer_fmt="${ps1_entry_fmt} ═ "
  fi

  bap_env_timestamp
  ps1_entry_raw="◷[${_bap_env_timestamp}]"
  ps1_entry_fmt="◷[${bap_ps1_ansi_green}${_bap_env_timestamp}${bap_ps1_ansi_reset}]"
  ps1_line_footer_raw="${ps1_line_footer_raw}${ps1_entry_raw}"
  ps1_line_footer_fmt="${ps1_line_footer_fmt}${ps1_entry_fmt}"

  # TODO: Maybe use this for timing command durations? "⧗hh:mm:ss.mmm"

  # ---
  # Build Header (OS/CHROOT/USER/...).
  # ---
  # OS info.
  ps1_entry_raw="${bap_ps1_os}"
  ps1_entry_fmt="${bap_ps1_ansi_dim}${bap_ps1_os}${bap_ps1_ansi_dim_reset}"
  # Start with entry and also separator character.
  ps1_line_header_raw=" ${ps1_entry_raw} ═"
  ps1_line_header_fmt=" ${ps1_entry_fmt} ═"

  # Optional CHROOT info.
  if [[ ! -z "${bap_ps1_chroot}" ]]; then
    ps1_entry_raw="${bap_ps1_chroot}"
    ps1_entry_fmt="${bap_ps1_ansi_dim}${bap_ps1_chroot}${bap_ps1_ansi_dim_reset}"
    # Append entry and also separator character.
    ps1_line_header_raw="${ps1_line_header_raw} ${ps1_entry_raw} ="
    ps1_line_header_fmt="${ps1_line_header_fmt} ${ps1_entry_fmt} ="
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
  # About previous command.
  # ---
  # Line 00: error code, timestamp
  bap_print_headline $bap_ps1_max_width ╘ ═ ╛ ${#ps1_line_footer_raw} "${ps1_line_footer_fmt}"
  # echo "${ps1_entry_exit}${ps1_entry_timestamp}"

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
  echo '$(bap_output_ps1_dir)' # Needs eval'd every time.

  # Line 04: Prompt.
  echo "└┤${bap_ps1_entry_prompt}"
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
    echo -e "├┬ ${bap_ansi_blue}${ps1_path_parent}/${bap_ansi_underline}${ps1_path_repo}${bap_ansi_underline_reset}${bap_ansi_yellow}/${ps1_path_rel}${bap_ansi_reset}"
    echo -e "│└─${ps1_entry_vc}"
  else
    # All one color.
    echo -e "├─ ${bap_ansi_blue}${PWD}${bap_ansi_reset}"
  fi
}


bap_setup_ps1() {
  PS1="$(bap_output_ps1)"
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
  #    "└┤$[bap_ps1_entry_prompt}"
  echo " │${bap_ps2_entry_prompt}"
}


bap_setup_ps2() {
  PS2="$(bap_output_ps2)"
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
    bap_prev_cmd_exit_status="⚠「${exit_code}」"
  fi

  bap_command_prev="$BASH_COMMAND"
}
