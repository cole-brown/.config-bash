

_usr_env_setup() {
  if ! get_this_dir $1; then
    echo "_usr_env.sh can't find _colors.sh"
    return 1
  else
    source "$this_dir/_colors.sh"
    _colors_setup "$this_dir"
  fi

  #--------------
  # About Me & Environment
  #--------------

  ps1_user="${ps1_color_green}\u@\h${ps1_color_reset}"
  ps1_dir="${ps1_color_blue}\w${ps1_color_reset}"
  ps1_time="${ps1_color_green}\t${ps1_color_reset}"
}
