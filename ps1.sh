# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

declare -i bap_ps1_max_width=80

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

get_this_dir() {
  # Just in case someone did something stupid like sent in '~' instead of '$HOME'... >.>
  local input_dir="$1"
  if [ ! -d "$input_dir" ]; then
    echo "Not a directory?: $input_dir"
    echo "If there's a tilde ('~') in there, use \$HOME maybe."
    echo "Need dir of ps1.sh for ps1_setup()"
    return 1
  fi

  if [ ! -f "${input_dir}/ps1.sh" ]; then
    echo "Don't see my source here..."
    echo "No '${input_dir}/ps1.sh' file?"
    return 1
  fi

  this_dir="$input_dir"
  return 0
}


# ------------------------------------------------------------------------------
# ==============================================================================
#                                -- Function --
# ==============================================================================
# ------------------------------------------------------------------------------

# ------------------------------
# Import Functions and such.
# ------------------------------
ps_import() {
  # ---
  # Make sure we know where we are.
  # ---
  if ! get_this_dir "$1"; then
    return $?
  fi
  local here="$this_dir"

  # ---
  # PS1 Command Prompt Stuff.
  # ---

  # ---
  # Colors: De-uglifying Color Codes
  # ---
  source "${here}/_ansi_codes.sh"
  bap_ansi_setup "$here"

  source "${here}/_print.sh"

  # ---
  # OS
  # ---
  source "${here}/_os.sh"
  _os_setup "$here"

  # ---
  # About Me & Environment
  # ---
  source "${here}/_usr_env.sh"
  _usr_env_setup "$here"

  # ---
  # Version Control
  # ---
  source "${here}/_vc.sh"
  _vc_setup "$here"
}


# ------------------------------
# PS1: Variables for ~prompt_command~ to fill for PS1.
# ------------------------------

declare ps1_exit_status=""
export ps1_exit_status

# ps1_entry_prompt="\$> "
ps1_entry_prompt="❯ "
ps2_entry_prompt="$ps1_prompt"


# ------------------------------
# PS1: The Main Prompt.
# ------------------------------
ps1_setup() {
  PS1="$(ps1_output)"
}


ps1_output() {

  # ------------------------------
  # Build the prompt:
  # ------------------------------

  # ---
  # Build Footer (exit code/timestamp/...).
  # ---
  # `ps1_exit_status` Will be set in ~prompt_command~
  local ps1_entry_raw='${ps1_exit_status}'
  local ps1_entry_fmt="${bap_ps1_ansi_red}"'${ps1_exit_status}'"${bap_ps1_ansi_reset}"

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
  ps1_entry_raw="${ps1_os}"
  ps1_entry_fmt="${bap_ps1_ansi_dim}${ps1_os}${bap_ps1_ansi_dim_reset}"
  # Start with entry and also separator character.
  ps1_line_header_raw=" ${ps1_entry_raw} ═"
  ps1_line_header_fmt=" ${ps1_entry_fmt} ═"

  # Optional CHROOT info.
  if [[ ! -z "${ps1_chroot}" ]]; then
    ps1_entry_raw="${ps1_chroot}"
    ps1_entry_fmt="${bap_ps1_ansi_dim}${ps1_chroot}${bap_ps1_ansi_dim_reset}"
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
  _ps1_print_line $bap_ps1_max_width ╘ ═ ╛ ${#ps1_line_footer_raw} "${ps1_line_footer_fmt}"
  # echo "${ps1_entry_exit}${ps1_entry_timestamp}"

  # ---
  # Intermission
  # ---
  bap_print_centered $bap_ps1_max_width "╶─╼━╾─╴"

  # ---
  # Prompt for this command.
  # ---

  # Line 01: OS, user/host, etc.
  # echo "${ps1_entry_os}:${ps1_entry_chroot}${ps1_user}"
  # _ps1_print_line $bap_ps1_max_width ╒ ═ ╕ "${ps1_fmt_line}"
  _ps1_print_line $bap_ps1_max_width ╒ ═ ╕ ${#ps1_line_header_raw} "${ps1_line_header_fmt}"

  # Line 02 (+03): Current Dir (+ Version Control Info)
  echo '$(ps1_output_dir)' # Needs eval'd every time.

  # Line 04: Prompt.
  echo "└┤${ps1_entry_prompt}"
}


ps1_output_dir() {
  # ------------------------------
  # Version Control
  # ------------------------------
  local ps1_entry_vc="${bap_ansi_yellow}$(_ps1_vc_)${bap_ansi_reset}"

  # ------------------------------
  # Directory
  # ------------------------------
  # Can't use "\w" when we're called every prompt and are explicitly echoing the dir.
  # local ps1_entry_dir=" ${bap_ps1_ansi_blue}${ps1_dir}${bap_ps1_ansi_reset}"

  # ------------------------------
  # Output Dir/VC lines.
  # ------------------------------
  if path_in_vc "$PWD"; then
    #local ps1_path_root="$_path_root_vc"

    # Split into root, relative if in a VC dir.
    local ps1_path_parent="$(dirname "$_path_root_vc")"
    local ps1_path_repo="$(basename "$_path_root_vc")"
    local ps1_path_rel="$(realpath --relative-to="$_path_root_vc" "$PWD")"

    # Repo's root path one color & relative path a second color.
    # Also, underline the repo name.
    echo -e "├┬ ${bap_ansi_blue}${ps1_path_parent}/${bap_ansi_underline}${ps1_path_repo}${bap_ansi_underline_reset}${bap_ansi_yellow}/${ps1_path_rel}${bap_ansi_reset}"
    echo -e "│└─${ps1_entry_vc}"
  else
    # All one color.
    echo -e "├─ ${bap_ansi_blue}${PWD}${bap_ansi_reset}"
  fi
}


# ------------------------------
# PS2: Used as prompt for incomplete commands.
# ------------------------------
ps2_setup() {
  PS2="$(ps2_output)"
}


ps2_output() {
  # ------------------------------
  # Set up PS2 variable
  # ------------------------------
  # PS1:
  #    "..."
  #    "└┤$[ps1_entry_prompt}"
  echo " │${ps2_entry_prompt}"
}


# ------------------------------
# PS3: Used as prompt for ~select~ statements.
# ------------------------------


# ------------------------------
# PS4: Prefix for statements during execution trace (~set -x~).
#   - Printed multiple times if multiple levels of indirection.
#   - Default is: "+ "
# ------------------------------


# ------------------------------
# Set-Up / Init for Prompts.
# ------------------------------
prompt_statement_setup() {
  local dir="$1"
  ps_import "$dir"
  ps1_setup
  ps2_setup
}


# ------------------------------------------------------------------------------
# Prompt Builder
# ------------------------------------------------------------------------------

prompt_command() {
  # ------------------------------
  # First: Exit Code
  # ------------------------------
  # This needs to be first in order to get the last command's exit code.
  local -i exit_code=$?

  # ------------------------------
  # Exit Code Status
  # ------------------------------

  if [[ $exit_code -eq 0 ]]; then
    ps1_exit_status=""
  else
    ps1_exit_status="⚠「${exit_code}」"
  fi
}
