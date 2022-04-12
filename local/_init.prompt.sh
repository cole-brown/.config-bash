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

source "${bap_path_root}/_text.sh"


# ------------------------------
# Configure `bap` settings...
# ------------------------------

case "$TERM" in
    *kitty*)
        # ---
        # `Kitty` terminal
        # ---
        # `Kitty` terminal doesn't dim the ASCII box lines ("╘══"), so try gray instead?
        bap_setting_text_weak_color="${bap_text_fmt_gray}"
        bap_setting_text_weak_dim=false
        ;;
    *)
        # ---
        # `Gnome Terminal`
        # ---
        # Use the defaults.
        ;;
esac



# ------------------------------------------------------------------------------
# Run Set-Up
# ------------------------------------------------------------------------------

if [[ -f "${bap_path_root}/init.sh" ]]; then
    source "${bap_path_root}/init.sh"
fi
