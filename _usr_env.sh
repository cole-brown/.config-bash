# ------------------------------------------------------------------------------
# Settings for the End User
# ------------------------------------------------------------------------------

_bap_ip_private_get="1.1.1.1" # Cloudflare
# _bap_ip_private_get="8.8.8.8" # Google
# _bap_ip_private_get="9.9.9.9" # Quad9

# Other IPs can be found:
#   https://docs.pi-hole.net/guides/dns/upstream-dns-providers/

_bap_ip_public_cmd="curl --silent ipinfo.io/ip 2>/dev/null"


# ------------------------------------------------------------------------------
# ==============================================================================
#                                -- Function --
# ==============================================================================
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# User & Host
# ------------------------------------------------------------------------------

_bap_env_ident=""
bap_env_ident() {
    _bap_env_ident="$(whoami)@$(hostname)"
}


_bap_env_timestamp=""
# _bap_env_timestamp_fmt="+%F %T%z" # timezone offset
_bap_env_timestamp_fmt="+%F %T %Z" # timezone name
bap_env_timestamp() {
    _bap_env_timestamp="$(date "$_bap_env_timestamp_fmt")"
    return $?
}


# ------------------------------------------------------------------------------
# Development Tier
# ------------------------------------------------------------------------------

_bap_env_dev_tier=""
bap_env_dev_tier() {
    _bap_env_dev_tier=""
    local host="$(hostname)"

    # Translate "dev"/"stg"/"stag"/"prd"/"prod" in the hostname into "dev/"stg"/"prd" string.
    if [[ "$host" =~ (^|[^[:alnum:]])dev([^[:alnum:]]|$) ]]; then
        _bap_env_dev_tier="dev"
        return 0
    elif [[ "$host" =~ (^|[^[:alnum:]])sta?g([^[:alnum:]]|$) ]]; then
        _bap_env_dev_tier="stg"
        return 0
    elif [[ "$host" =~ (^|[^[:alnum:]])pro?d([^[:alnum:]]|$) ]]; then
        _bap_env_dev_tier="prd"
        return 0
    fi

    return 1
}


# ------------------------------------------------------------------------------
# IP Addresses
# ------------------------------------------------------------------------------

_bap_env_ip_addr_private=""
bap_env_ip_addr_private() {
    local setup_ip=$1 # Should be true/false.
    local -i exitcode=0

    if $setup_ip ; then
        # This command return something like:
        #   $ ip route get 8.8.8.8
        #   > 8.8.8.8 via 192.168.254.254 dev enx381428bf81ce src 192.168.254.74 uid 1001
        local ip_route="$(ip route get $_bap_ip_private_get 2>/dev/null)"
        exitcode=$?
        if [[ $exitcode -ne 0 ]]; then
            _bap_env_ip_addr_private="¿local-ip?"
            return $exitcode
        fi

        # Now trim down to private IP: grab only first line, then get the correct field number.
        _bap_env_ip_addr_private="$(echo "$ip_route" | head -1 | cut -d' ' -f7)"

        # Found nothing?
        if [[ -z "$_bap_env_ip_addr_private" ]]; then
            _bap_env_ip_addr_private="¿local-ip?"
        fi
    else
        _bap_env_ip_addr_private=""
    fi

    return $exitcode
}


_bap_env_ip_addr_public=""
bap_env_ip_addr_public() {
    # Could split up public/private as separate settings if desired...
    local setup_ip=$1 # Should be true/false.
    local -i exitcode=0

    if $setup_ip ; then
        # Expect the command to do all the work to trim, etc.
        _bap_env_ip_addr_public="$($_bap_ip_public_cmd)"
        exitcode=$?
        if [[ -z "$_bap_env_ip_addr_public" ]]; then
            _bap_env_ip_addr_public="¿public-ip?"
        fi
        if [[ $exitcode -ne 0 ]]; then
            return $exitcode
        fi
    else
        _bap_env_ip_addr_public=""
    fi

    return 0
}


# ------------------------------------------------------------------------------
# Set-Up
# ------------------------------------------------------------------------------

bap_usr_env_setup() {
    local path_include="$1"
    local setup_ip=$2

    bap_env_ip_addr_public $setup_ip
    bap_env_ip_addr_private $setup_ip
}
