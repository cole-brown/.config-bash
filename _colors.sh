# TODO: Rename this file - not just for colors anymore.

# TODO: split into smaller functions or leave as a big single?

# TODO: More format codes:
#   - https://misc.flogisoft.com/bash/tip_colors_and_formatting
#     - Left off at "8/16 Colors"
_colors_setup() {
  # ------------------------------
  # ANSI Codes
  # ------------------------------

  # Colors
  ansi_color_reset="\033[00m"
  ansi_color_red="\033[0;31m"
  ansi_color_green="\033[01;32m"
  ansi_color_yellow="\033[0;33m"
  ansi_color_blue="\033[01;34m"
  ansi_color_purple="\033[0;35m"
  ansi_color_teal="\033[0;36m"

  # Inverts foreground and background colors.
  # AKA "reverse"
  ansi_color_invert="\e[7m"

  # Text properties
  ansi_format_reset="\e[0m"
  ansi_format_bold="\e[1m"
  ansi_format_dim="\e[2m"
  ansi_format_italic="\e[3m"
  ansi_format_underline="\e[4m"
  ansi_format_blink="\e[5m"
  ansi_format_hidden="\e[8m" # For e.g. passwords.
  ansi_format_strikethrough="\e[9m"

  ansi_format_bold_reset="\e[21m"
  ansi_format_dim_reset="\e[22m"
  ansi_format_italic_reset="\e[23m"
  ansi_format_underline_reset="\e[24m"
  ansi_format_blink_reset="\e[25m"
  ansi_format_hidden_reset="\e[28m"
  ansi_format_strikethrough_reset="\e[29m"


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

  ps1_color_invert="\[${ansi_color_invert}\]"

  ps1_format_reset="\[${ansi_format_reset}\]"
  ps1_format_bold="\[${ansi_format_bold}\]"
  ps1_format_dim="\[${ansi_format_dim}\]"
  ps1_format_italic="\[${ansi_format_italic}\]"
  ps1_format_underline="\[${ansi_format_underline}\]"
  ps1_format_blink="\[${ansi_format_blink}\]"
  ps1_format_hidden="\[${ansi_format_hidden}\]"
  ps1_format_strikethrough="\[${ansi_format_strikethrough}\]"

  ps1_format_bold_reset="\[${ansi_format_bold_reset}\]"
  ps1_format_dim_reset="\[${ansi_format_dim_reset}\]"
  ps1_format_italic_reset="\[${ansi_format_italic_reset}\]"
  ps1_format_underline_reset="\[${ansi_format_underline_reset}\]"
  ps1_format_blink_reset="\[${ansi_format_blink_reset}\]"
  ps1_format_hidden_reset="\[${ansi_format_hidden_reset}\]"
  ps1_format_strikethrough_reset="\[${ansi_format_strikethrough_reset}\]"
}
