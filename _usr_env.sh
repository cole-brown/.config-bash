# ------------------------------------------------------------------------------
# Settings for the End User
# ------------------------------------------------------------------------------

_bap_ip_private_get="1.1.1.1" # Cloudflare
# _bap_ip_private_get="8.8.8.8" # Google
# _bap_ip_private_get="9.9.9.9" # Quad9

# Other IPs can be found:
#   https://docs.pi-hole.net/guides/dns/upstream-dns-providers/

_bap_ip_public_cmd="curl --silent ipinfo.io/ip"


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
    local ip_route="$(ip route get $_bap_ip_private_get)"
    exitcode=$?
    if [[ $exitcode -ne 0 ]]; then
      return $exitcode
    fi

    # Now trim down to private IP: grab only first line, then get the correct field number.
    _bap_env_ip_addr_private="$(echo "$ip_route" | head -1 | cut -d' ' -f7)"
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
