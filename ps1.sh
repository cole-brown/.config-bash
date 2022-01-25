
#--------------------
# Helpers
#--------------------

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


#--------------------------
#==========================
#      -- Function --
#==========================
#--------------------------

# PS1: The Main Prompt.
ps1_setup() {
  #--------------------------
  # Make sure we know where we are.
  #--------------------------
  if ! get_this_dir "$1"; then
    return $?
  fi
  local here="$this_dir"

  #--------------------------
  # PS1 Command Prompt Stuff.
  #--------------------------

  #--------------
  # Colors: De-uglifying Color Codes
  #--------------
  source "${here}/_colors.sh"
  _colors_setup "$here"

  #--------------
  # OS
  #--------------
  source "${here}/_os.sh"
  _os_setup "$here"

  #--------------
  # About Me & Environment
  #--------------
  source "${here}/_usr_env.sh"
  _usr_env_setup "$here"

  #--------------
  # Version Control
  #--------------
  source "${here}/_vc.sh"
  _vc_setup "$here"
  local vc_pre="$(_ps1_vc_pre_)"
  local vc_post="$(_ps1_vc_post_)"
  local vc_dynamic='$(_ps1_vc_)'

  # ------------------------------
  # Directory
  # ------------------------------
  # A separate line for the directory path, since it tends to be long?
  # local ps1_dir="  ├📂 ${ps1_dir}"
  local ps1_dir="  ├─ ${ps1_dir}"

  #--------------
  # Prompt: $> cmd.exe
  #--------------
  local ps1_prompt="  └──┤${ps1_time}├─\$> "

  #--------------
  # Full PS1 Line
  #--------------
  # # 2 lines, e.g.:
  # #   > 20.04(focal):work@work-2021-lap:~/path/to/repositories/foobar (feature/123--ascii-art)
  # #   >   └──┤16:39:52├─$>
  # ps1_full_line="${ps1_os}:${ps1_deb_chroot}${ps1_user}:${ps1_dir}${vc_pre}${vc_dynamic}${vc_post}\n ${ps1_prompt}"

  # 3 lines, e.g.:
  #   > 20.04(focal):work@work-2021-lap git(feature/prod-123--sftp-server)
  #   >   ├─ ~/ocean/repositories/terraform/tier/development/customizer/sftp/ansible
  #   >   └──┤15:08:57├─$>
  ps1_full_line="${ps1_os}:${ps1_deb_chroot}${ps1_user}:${vc_pre}${vc_dynamic}${vc_post}\n${ps1_dir}\n${ps1_prompt}"
}


# PS2: Used as prompt for incomplete commands.
ps2_setup() {
  # Continuation prompt (PS2): Same length as PS1.
  #                "  └──┤HH:MM:SS├─\$> "
  local ps2_prompt="     └──────────\$> "

  ps2_full_line="${ps2_prompt}"
}


# PS3: Used as prompt for ~select~ statements.


# PS4: Prefix for statements during execution trace (~set -x~).
#   - Printed multiple times if multiple levels of indirection.
#   - Default is: "+ "


prompt_statement_setup() {
  local dir="$1"
  ps1_setup "$dir"
  ps2_setup
}


_config_spy_ps1_full_line() {
  echo "${ps1_full_line}"
}

_config_spy_ps2_full_line() {
  echo "${ps2_full_line}"
}
