bap_usr_env_setup() {
  #--------------
  # About Me & Environment
  #--------------
  # Bash PS1 variables:
  #   https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
  #   https://ss64.com/bash/syntax-prompt.html

  bap_ps1_user="\u@\h"
  bap_ps1_dir="\w"

  # Date, Time, or Datetime
  bap_ps1_date="\D{%F}"
  bap_ps1_time="\t"
  # ISO-8601 with " " separator instead of "T".
  bap_ps1_datetime="\D{%F %T}"
}


_bap_env_ident=""
bap_env_ident() {
  _bap_env_ident="$(whoami)@$(hostname)"
}


_bap_env_timestamp=""
# _bap_env_timestamp_fmt="+%F %T%z" # timezone offset
_bap_env_timestamp_fmt="+%F %T %Z" # timezone name
bap_env_timestamp() {
  _bap_env_timestamp="$(date "$_bap_env_timestamp_fmt")"
}
