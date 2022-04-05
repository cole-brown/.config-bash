# ------------------------------------------------------------------------------
# Example for a "bash.secret.sh" file:
# ------------------------------------------------------------------------------

# Source this file.

# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------

# Comment out or set to false to disable.
dc_print_banner=true


# ------------------------------------------------------------------------------
# Expected Variables
# ------------------------------------------------------------------------------
#
# dc_ip_addr=""
#
# dc_title=""
# dc_profile=""
#
# # dev, stg, prd
# dc_tier_short=""
#
# # development, staging, production
# dc_tier_long=""


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

dc_setup_for_user_ip() {
    dc_ip_addr="$(w --no-header | awk '{print $3}')"
    # Do we need to grep for user (will any other users be logged in at same time)?
    # dc_ip_addr="$(w --no-header | grep $USER | awk '{print $3}')"

    # Is user logging in from VPN? If so we can figure out the Development Tier from the IP.
    if [[ $dc_ip_addr =~ ^10\.0\.0 ]]; then
        dc_tier_short="dev"
        dc_tier_long="development"
        dc_props_tier="$dc_props_dev"
    elif [[ $dc_ip_addr =~ ^10\.0\.1 ]]; then
        dc_tier_short="stg"
        dc_tier_long="staging"
        dc_props_tier="$dc_props_stg"
    elif [[ $dc_ip_addr =~ ^10\.0\.2 ]]; then
        dc_tier_short="prd"
        dc_tier_long="PRODUCTION"
        dc_props_tier="$dc_props_prd"
    fi

    # And we can figure out the user from the IP as well.
    if [[ $dc_ip_addr =~ ^10\.0\.[012]\.200$ ]]; then
        dc_profile="developer200"
    elif [[ $dc_ip_addr =~ ^10\.0\.[012]\.201$ ]]; then
        dc_profile="jeff"
    fi
}


dc_secret_setup() {
    dc_title="Head Crash, LLC"

    dc_setup_for_user_ip
}


# ------------------------------------------------------------------------------
# Script
# ------------------------------------------------------------------------------
# Runs when sourced...

dc_secret_setup
