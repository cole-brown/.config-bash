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
  source "${here}/_colors.sh"
  _colors_setup "$here"

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
  # Info about What Just Happened
  # ------------------------------
  # `ps1_exit_status` Will be set in ~prompt_command~
  local ps1_entry_exit="${ps1_color_red}"'${ps1_exit_status}'"${ps1_color_reset}"
  local ps1_entry_timestamp="◷[${ps1_datetime}]"
  # Maybe use this for timing commands? "⧗hh:mm:ss.mmm"


  # ------------------------------
  # Output the prompt:
  # ------------------------------
  echo "${ps1_entry_exit}${ps1_entry_timestamp}"
  echo "${ps1_os}:${ps1_deb_chroot}${ps1_user}"
  echo '$(ps1_output_dir)' # Needs eval'd every time.
  echo "└┤${ps1_entry_prompt}"
}


ps1_output_dir() {
  # ------------------------------
  # Version Control
  # ------------------------------
  local ps1_entry_vc="$(_ps1_vc_pre_)$(_ps1_vc_)$(_ps1_vc_post_)"

  # ------------------------------
  # Directory
  # ------------------------------
  # Can't use "\w" when we're called every prompt and are explicitly echoing the dir.
  # local ps1_entry_dir=" ${ps1_dir}"

  # TODO: split into root, relative if in a VC dir.

  # ------------------------------
  # Output Dir/VC lines.
  # ------------------------------
  if path_in_vc "$PWD"; then
    #local ps1_path_root="$_path_root_vc"
    local ps1_path_parent="$(dirname "$_path_root_vc")"
    local ps1_path_repo="$(basename "$_path_root_vc")"
    local ps1_path_rel="$(realpath --relative-to="$_path_root_vc" "$PWD")"
    # Repo's root path one color & relative path a second color.
    # Also, underline the repo name.
    echo -e "├┬ ${ansi_color_blue}${ps1_path_parent}/${ansi_format_underline}${ps1_path_repo}${ansi_format_underline_reset}${ansi_color_yellow}/${ps1_path_rel}${ansi_color_reset}"
    echo -e "│└─${ps1_entry_vc}"
  else
    # All one color.
    echo -e "├─ ${ansi_color_blue}${PWD}${ansi_color_reset}"
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
