# TODO: Split into smaller functions or leave as a big single?
#   - Make a function for generating codes instead of creating all these variables?

# TODO: More format codes:
#   - https://misc.flogisoft.com/bash/tip_colors_and_formatting
#     - Left off at "8/16 Colors"
bap_ansi_setup() {
  # ------------------------------
  # ANSI Codes
  # ------------------------------

  # ---
  # General
  # ---
  # These are all just the escape key, basically.
  # bap_ansi_escape_oct="\033" # octal 33
  # bap_ansi_escape_hex="\x1b" # hex   1b
  bap_ansi_escape="\e"

  bap_ansi_reset="${bap_ansi_escape}[0m"

  # ---
  # Colors
  # ---
  bap_ansi_red="${bap_ansi_escape}[0;31m"
  bap_ansi_green="${bap_ansi_escape}[01;32m"
  bap_ansi_yellow="${bap_ansi_escape}[0;33m"
  bap_ansi_blue="${bap_ansi_escape}[01;34m"
  bap_ansi_purple="${bap_ansi_escape}[0;35m"
  bap_ansi_teal="${bap_ansi_escape}[0;36m"

  # Inverts foreground and background colors.
  # AKA "reverse"
  bap_ansi_invert="${bap_ansi_escape}[7m"

  # ---
  # Text Properties
  # ---
  bap_ansi_bold="${bap_ansi_escape}[1m"
  bap_ansi_dim="${bap_ansi_escape}[2m"
  bap_ansi_italic="${bap_ansi_escape}[3m"
  bap_ansi_underline="${bap_ansi_escape}[4m"
  bap_ansi_blink="${bap_ansi_escape}[5m"
  bap_ansi_hidden="${bap_ansi_escape}[8m" # For e.g. passwords.
  bap_ansi_strikethrough="${bap_ansi_escape}[9m"

  bap_ansi_bold_reset="${bap_ansi_escape}[21m"
  bap_ansi_dim_reset="${bap_ansi_escape}[22m"
  bap_ansi_italic_reset="${bap_ansi_escape}[23m"
  bap_ansi_underline_reset="${bap_ansi_escape}[24m"
  bap_ansi_blink_reset="${bap_ansi_escape}[25m"
  bap_ansi_hidden_reset="${bap_ansi_escape}[28m"
  bap_ansi_strikethrough_reset="${bap_ansi_escape}[29m"

  # ------------------------------
  # PS1 Codes
  # ------------------------------
  # "\[" + ANSI Code + "\]"
  # The escaped brackets help Bash count how long the prompt actually is or something.

  # ---
  # General
  # ---
  bap_ps1_ansi_reset="\[${bap_ansi_reset}\]"

  # ---
  # Colors
  # ---
  bap_ps1_ansi_red="\[${bap_ansi_red}\]"
  bap_ps1_ansi_green="\[${bap_ansi_green}\]"
  bap_ps1_ansi_yellow="\[${bap_ansi_yellow}\]"
  bap_ps1_ansi_blue="\[${bap_ansi_blue}\]"
  bap_ps1_ansi_purple="\[${bap_ansi_purple}\]"
  bap_ps1_ansi_teal="\[${bap_ansi_teal}\]"

  bap_ps1_ansi_invert="\[${bap_ansi_invert}\]"

  # ---
  # Text Properties
  # ---
  bap_ps1_ansi_bold="\[${bap_ansi_bold}\]"
  bap_ps1_ansi_dim="\[${bap_ansi_dim}\]"
  bap_ps1_ansi_italic="\[${bap_ansi_italic}\]"
  bap_ps1_ansi_underline="\[${bap_ansi_underline}\]"
  bap_ps1_ansi_blink="\[${bap_ansi_blink}\]"
  bap_ps1_ansi_hidden="\[${bap_ansi_hidden}\]"
  bap_ps1_ansi_strikethrough="\[${bap_ansi_strikethrough}\]"

  bap_ps1_ansi_bold_reset="\[${bap_ansi_bold_reset}\]"
  bap_ps1_ansi_dim_reset="\[${bap_ansi_dim_reset}\]"
  bap_ps1_ansi_italic_reset="\[${bap_ansi_italic_reset}\]"
  bap_ps1_ansi_underline_reset="\[${bap_ansi_underline_reset}\]"
  bap_ps1_ansi_blink_reset="\[${bap_ansi_blink_reset}\]"
  bap_ps1_ansi_hidden_reset="\[${bap_ansi_hidden_reset}\]"
  bap_ps1_ansi_strikethrough_reset="\[${bap_ansi_strikethrough_reset}\]"
}


# Strip ANSI (and PS1) escape sequences from input string.
_bap_ansi_strip=""
bap_ansi_strip() {
  _bap_ansi_strip=""
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
  _bap_ansi_strip="$(echo -e "$string" | sed 's/\\[?\x1B\[[0-9;]*[a-zA-Z]//g')"
  return $?
}

