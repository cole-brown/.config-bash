# Source this in .bashrc or something.

# ╔══════════════════════════════════════════════════════════════════════════╗ #
# ║                        bap - Bourne Again Prompt                         ║ #
# ╠══════════════════════════════════════════════════════════════════════════╣ #
# ║                       Features:                                          ║ #
# ║                           1. Timestamps                                  ║ #
# ║                           2. Too many lines                              ║ #
# ║                           3. Non-ASCII characters                        ║ #
# ╚══════════════════════════════════════════════════════════════════════════╝ #


bap_path_this="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
bap_path_root="${bap_path_this}/.."


# ------------------------------------------------------------------------------
# Settings, etc.
# ------------------------------------------------------------------------------

# ------------------------------
# Load some `bap` variables...
# ------------------------------

# Currently don't need to since we have only default settings.


# ------------------------------
# Configure `bap` settings...
# ------------------------------

# Currently all settings are default for local.


# ------------------------------------------------------------------------------
# Run Set-Up
# ------------------------------------------------------------------------------

if [[ -f "${bap_path_root}/init.sh" ]]; then
    source "${bap_path_root}/init.sh"
fi
