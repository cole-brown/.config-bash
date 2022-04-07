# Source this file.


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

# ------------------------------
# Import
# ------------------------------

bap_init_import() {
  local import_path="$1"
  source "$import_path/_path.sh"

  # ---
  # Make sure we know where we are.
  # ---
  if ! bap_script_dir "$import_path"; then
    return $?
  fi

  # ---
  # Import all the BAP functionality.
  # ---

  # Colors: De-uglifying Color Codes
  source "${_bap_script_dir}/_ansi_codes.sh"
  bap_ansi_setup "$_bap_script_dir"

  # Output Helpers
  source "${_bap_script_dir}/_print.sh"
  if ! bap_print_setup "$_bap_script_dir"; then
    return $?
  fi

  # OS Info
  source "${_bap_script_dir}/_os.sh"
  bap_os_setup "$_bap_script_dir"

  # Timing Info
  source "${_bap_script_dir}/_timer.sh"
  bap_timer_setup "$_bap_script_dir"

  # About Me & Environment
  source "${_bap_script_dir}/_usr_env.sh"
  bap_usr_env_setup "$_bap_script_dir" $( $bap_show_ip_in_header || $bap_show_ip_in_subheader )

  # Version Control
  source "${_bap_script_dir}/_vc.sh"
  bap_vc_setup "$_bap_script_dir"
}


# ------------------------------
# Set-Up / Init the Prompts.
# ------------------------------

bap_init_setup() {
  bap_setup_ps0
  bap_setup_ps1
  bap_setup_ps2
}
