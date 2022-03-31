# TODO: Rename this file - not just for colors anymore.

# TODO: split into smaller functions or leave as a big single?

# TODO: More format codes:
#   - https://misc.flogisoft.com/bash/tip_colors_and_formatting
#     - Left off at "8/16 Colors"
_colors_setup() {
  # ------------------------------
  # ANSI Codes
  # ------------------------------
  # These are all just the escape key, basically.
  char_escape_oct="\033" # octal 33
  char_escape_hex="\x1b" # hex   1b
  char_escape="\e"

  # Colors
  ansi_color_reset="${char_escape}[00m"
  ansi_color_red="${char_escape}[0;31m"
  ansi_color_green="${char_escape}[01;32m"
  ansi_color_yellow="${char_escape}[0;33m"
  ansi_color_blue="${char_escape}[01;34m"
  ansi_color_purple="${char_escape}[0;35m"
  ansi_color_teal="${char_escape}[0;36m"

  # Inverts foreground and background colors.
  # AKA "reverse"
  ansi_color_invert="${char_escape}[7m"

  # Text properties
  ansi_format_reset="${char_escape}[0m"
  ansi_format_bold="${char_escape}[1m"
  ansi_format_dim="${char_escape}[2m"
  ansi_format_italic="${char_escape}[3m"
  ansi_format_underline="${char_escape}[4m"
  ansi_format_blink="${char_escape}[5m"
  ansi_format_hidden="${char_escape}[8m" # For e.g. passwords.
  ansi_format_strikethrough="${char_escape}[9m"

  ansi_format_bold_reset="${char_escape}[21m"
  ansi_format_dim_reset="${char_escape}[22m"
  ansi_format_italic_reset="${char_escape}[23m"
  ansi_format_underline_reset="${char_escape}[24m"
  ansi_format_blink_reset="${char_escape}[25m"
  ansi_format_hidden_reset="${char_escape}[28m"
  ansi_format_strikethrough_reset="${char_escape}[29m"


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


# Strip ANSI (and PS1) escape sequences from input string.
_ansi_string_strip=""
ansi_string_strip() {
  _ansi_string_strip=""
  local string="$@"

  # No input == error.
  if [[ -z "$string" ]]; then
    return 1
  fi

  # Using [a-zA-Z], which is all escape sequences.
  #
  # If you want to restrict to just certain escape sequences:
  # ----------------------------------------------
  # Last escape sequence...
  #   Character   Purpose
  #   ---------   -------------------------------
  #   m           Graphics Rendition Mode (including Color)
  #   G           Horizontal cursor move
  #   K           Horizontal deletion
  #   H           New cursor position
  #   F           Move cursor to previous n lines

  # https://superuser.com/a/380778
  #
  # Search for ANSI escape sequences, replace with nothing.
  _ansi_string_strip="$(echo -e "$string" | sed 's/\\[?\x1B\[[0-9;]*[a-zA-Z]//g')"
  return $?
}

