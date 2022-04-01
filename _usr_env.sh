bap_usr_env_setup() {
  if ! get_this_dir $1; then
    echo "_usr_env.sh can't find _ansi_codes.sh"
    return 1
  else
    source "${this_dir}/_ansi_codes.sh"
    bap_ansi_setup "$this_dir"
  fi

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
_bap_env_timestamp_fmt="+%F %T"
bap_env_timestamp() {
  _bap_env_timestamp="$(date "$_bap_env_timestamp_fmt")"
}
