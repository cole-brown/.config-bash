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

# ------------------------------
# PS1: The Main Prompt.
# ------------------------------
ps1_setup() {
  # ------------------------------
  # Info about What Just Happened
  # ------------------------------
  # `ps1_exit_status` Will be set in ~prompt_command~
  local ps1_entry_exit="${ps1_color_red}"'${ps1_exit_status}'"${ps1_color_reset}"
  local ps1_entry_timestamp="◷ ${ps1_datetime}"
  # Maybe use this for timing commands? "⧗hh:mm:ss.mmm"

  #--------------------------
  # Version Control
  #--------------------------
  local vc_pre="$(_ps1_vc_pre_)"
  local vc_post="$(_ps1_vc_post_)"
  local vc_dynamic='$(_ps1_vc_)'
  local ps1_entry_vc="${vc_pre}${vc_dynamic}${vc_post}"

  # ------------------------------
  # Directory
  # ------------------------------
  # A separate line for the directory path, since it tends to be long?
  # local ps1_dir='  ├📂 ${ps1_dir}'
  local ps1_entry_dir="  ├─ ${ps1_dir}"

  #--------------
  # Prompt: $> cmd.exe
  #--------------
  # local ps1_prompt='  └──┤${ps1_time}├─\$> '
  local ps1_entry_prompt="  └─┤\$> "

  # ------------------------------
  # Set up PS1 variable
  # ------------------------------
  ps1_line_1="${ps1_entry_exit}${ps1_entry_timestamp}"
  ps1_line_2="${ps1_os}:${ps1_deb_chroot}${ps1_user}:${ps1_entry_vc}"
  ps1_line_3="${ps1_entry_dir}"
  ps1_line_4="${ps1_entry_prompt}"
  PS1="${ps1_line_1}\n${ps1_line_2}\n${ps1_line_3}\n${ps1_line_4}"
}


# ------------------------------
# PS2: Used as prompt for incomplete commands.
# ------------------------------
ps2_setup() {
  # ------------------------------
  # Set up PS2 variable
  # ------------------------------
  # Continuation prompt (PS2): Same length as HH.
  # #                "  └──┤PS1:MM:SS├─\$> "
  # local ps2_prompt="     └──────────\$> "
  #                "  └─┤\$> "
  local ps2_prompt="    └\$> "
  PS2="${ps2_prompt}"
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
  # Exit Code & Exit Time
  # ------------------------------

  if [[ $exit_code -eq 0 ]]; then
    ps1_exit_status=""
  else
    ps1_exit_status="⚠「${exit_code}」"
  fi
}
