
_colors_setup() {
  ansi_color_reset="\033[00m"
  ansi_color_red="\033[0;31m"
  ansi_color_green="\033[01;32m"
  ansi_color_yellow="\033[0;33m"
  ansi_color_blue="\033[01;34m"
  ansi_color_purple="\033[0;35m"
  ansi_color_teal="\033[0;36m"

  #--------------
  # PS1 Colors: De-uglifying Color Codes
  #--------------

  ps1_color_reset="\[${ansi_color_reset}\]"
  ps1_color_red="\[${ansi_color_red}\]"
  ps1_color_green="\[${ansi_color_green}\]"
  ps1_color_yellow="\[${ansi_color_yellow}\]"
  ps1_color_blue="\[${ansi_color_blue}\]"
  ps1_color_purple="\[${ansi_color_purple}\]"
  ps1_color_teal="\[${ansi_color_teal}\]"
}
