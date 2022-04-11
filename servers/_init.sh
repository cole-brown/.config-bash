# Source this file.


# ------------------------------------------------------------------------------
# DC Bash Set-Up
# ------------------------------------------------------------------------------

_dc_path_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

dc_feature_motd=false
dc_feature_prompt=false


# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------

dc_ip_addr=""

dc_title=""
dc_profile=""

# dev, stg, prd
dc_tier_short=""

# development, staging, production
dc_tier_long=""


# ------------------------------------------------------------------------------
# Script: Do set-up; print banner?
# ------------------------------------------------------------------------------

# ------------------------------
# Set-Up Secrets
# ------------------------------
# Anything I don't want source controlled goes in here:
if [[ -f "${_dc_path_script}/_secret.sh" ]]; then
    source "${_dc_path_script}/_secret.sh"
fi


# ------------------------------
# Set-Up: Message of the Day?
# ------------------------------
if $dc_feature_motd && [[ -f "${_dc_path_script}/_init.motd.sh" ]]; then
    source "${_dc_path_script}/_init.motd.sh"
fi


# ------------------------------
# Set-Up: Prompt?
# ------------------------------
if $dc_feature_prompt && [[ -f "${_dc_path_script}/_init.prompt.sh" ]]; then
    source "${_dc_path_script}/_init.prompt.sh"
fi


# ------------------------------
# Set-Up: Extras?
# ------------------------------
# Source user's extra bash set-up if it exists.
if [[ -n "$dc_profile" ]] && [[ -f "${HOME}/.${dc_profile}/.bashrc" ]]; then
    source "${HOME}/.${dc_profile}/.bashrc"
fi
