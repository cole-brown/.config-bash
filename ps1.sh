
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

  #--------------
  # Prompt: $> cmd.exe
  #--------------
  local ps1_prompt=" └──┤${ps1_time}├─\$> "

  #--------------
  # Full PS1 Line
  #--------------
  ps1_full_line="${ps1_os}:${ps1_deb_chroot}${ps1_user}:${ps1_dir}${vc_pre}${vc_dynamic}${vc_post}\n ${ps1_prompt}"
  ps2_full_line=" ${ps1_prompt}"
}


_config_spy_ps1_full_line() {
  echo "${ps1_full_line}"
}

_config_spy_ps2_full_line() {
  echo "${ps2_full_line}"
}
