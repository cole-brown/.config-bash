# ╔══════════════════════════════════════════════════════════════════════════╗ #
# ║                        bap - Bourne Again Prompt                         ║ #
# ╠══════════════════════════════════════════════════════════════════════════╣ #
# ║ A Bash Prompt that uses Functions and Variables, and can be understood?* ║ #
# ║                                    :o                                    ║ #
# ╚══════════════════════════════════════════════════════════════════════════╝ #
# *Understanding not guarenteed.


# ------------------------------------------------------------------------------
# Settings for the End User
# ------------------------------------------------------------------------------

bap_ps1_max_width=80

bap_prev_cmd_exit_quote_left="「"
bap_prev_cmd_exit_quote_right="」"
# Those are 2 chars wide:
bap_prev_cmd_exit_quote_left_eqiv="--"
bap_prev_cmd_exit_quote_right_eqiv="--"


bap_ps1_prompt_info="${bap_ps1_prompt_info:-}" # Just before `bap_ps1_prompt_symbol`.
bap_ps2_prompt_info="${bap_ps2_prompt_info:-}" # Just before `bap_ps2_prompt_symbol`.

# bap_ps1_prompt_symbol="\$> "
bap_ps1_prompt_symbol="${bap_ps1_prompt_symbol:-❯ }"
bap_ps2_prompt_symbol="${bap_ps2_prompt_symbol:-$bap_ps1_prompt_symbol}"


bap_show_ip_in_header=${bap_show_ip_in_header:-true}
bap_show_ip_in_subheader=${bap_show_ip_in_subheader:-false}
bap_show_tier=${bap_show_tier:-false}


# ------------------------------------------------------------------------------
# Constants & Variables
# ------------------------------------------------------------------------------

declare bap_prev_cmd_exit_status=""
export bap_prev_cmd_exit_status

# Was the previous prompt a command that was run, or a Ctrl-C, empty prompt, etc?
_bap_cmd_ran=false


# ------------------------------------------------------------------------------
# ==============================================================================
#                                -- Function --
# ==============================================================================
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------

bap_cmd_ran() {
    local -i timer_pid=$1

    if $_bap_cmd_ran ; then
        return 0
    fi

    if bap_timer_valid $timer_pid; then
        return 0
    fi

    return 1
}


bap_cmd_errored() {
    local -i timer_pid=$1

    # Command can only error if it ran.
    if bap_cmd_ran $_bap_timer_pid ; then
        test -n "$bap_prev_cmd_exit_status"
        return $?
    fi

    # Command did not error.
    return 1
}


# ------------------------------------------------------------------------------
# PS0: Runs right /before/ the command is executed.
# ------------------------------------------------------------------------------

bap_output_ps0() {
    bap_timer_start $_bap_timer_pid

    _bap_cmd_ran=true
}


# ------------------------------------------------------------------------------
# PS1: The Main Prompt.
# ------------------------------------------------------------------------------

# NOTE: Oddity with Bash Escape Sequences and Numbers:
#   Because we want the time right after an escape sequence, the leading digit
#   tends to get stripped for some fun reason if we just build the string like:
#     x="${y}${z}..."
#   So... echo the string in pieces, evaluating the escape codes as we go...

bap_output_ps1_footer() {
    local ps1_entry_raw=""

    # ------------------------------
    # Line -1: Blank line to separate out teh actual command a bit.
    # ------------------------------
    bap_text_out_newline

    # ------------------------------
    # Line 00: Footer
    # ------------------------------
      # Left corner of the line...
    ps1_entry_raw="╘"
    local -i width_curr=${#ps1_entry_raw}
    bap_text_out "${bap_text_weak_full}${ps1_entry_raw}"

    # ---
    # Error Code
    # ---
    # `bap_prev_cmd_exit_status` is set in `bap_prompt_command`.
    # Display it in the prompt if it's not empty string.
    #   - However, do not display it if the timer is invalid. Invalid timer
    #     suggests the error exit code was from a while ago and thus stale.
    if bap_cmd_errored $_bap_timer_pid; then
        # Print error code & spacer.
        ps1_entry_raw="${bap_prev_cmd_exit_quote_left_eqiv}${bap_prev_cmd_exit_status}${bap_prev_cmd_exit_quote_right_eqiv}═"
        width_curr=$(($width_curr + ${#ps1_entry_raw}))

        bap_text_out "${bap_text_fmt_reset}${bap_text_fmt_red}"
        bap_text_out "${bap_prev_cmd_exit_quote_left}${bap_prev_cmd_exit_status}${bap_prev_cmd_exit_quote_right}"
        bap_text_out "${bap_text_fmt_reset}${bap_text_weak_full}═"
    fi

    # ---
    # Command Timer
    # ---
    # TODO: Maybe nicer format for longer durations? "⧗hh:mm:ss.mmm"
    #   - Currently just "s.mmm"
    bap_timer_stop $_bap_timer_pid
    if [[ -n "$_bap_timer_duration" ]]; then
        # Print timer.
        ps1_entry_raw="⧗${_bap_timer_duration}"
        width_curr=$(($width_curr + ${#ps1_entry_raw}))

        bap_text_out "⧗${bap_text_weak_reset}"
        bap_text_out "${_bap_timer_duration}"

        # Print spacer.
        ps1_entry_raw="═"
        width_curr=$(($width_curr + ${#ps1_entry_raw}))
        bap_text_out "${bap_text_weak_full}${ps1_entry_raw}"
    fi

    # ---
    # MIDDLE FILL SHOULD GO HERE!!!
    # ---
    # But first we need to figure out how wide the right-hand side stuff is...

    # ---
    # Date & Time : Part 01
    # ---
    # Figure out width so we can make fill.
    bap_env_timestamp
    # Including the ending corner.
    ps1_entry_raw="◷[${_bap_env_timestamp}]╛"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    # ---
    # MIDDLE FILL DOES GO HERE!!!
    # ---
    bap_terminal_width $bap_ps1_max_width
    bap_text_out_fill $(($_bap_terminal_width - $width_curr)) ═

    # ---
    # Date & Time : Part 02
    # ---
    # Actually print it (w/ ending corner).
    bap_text_out "◷[${bap_text_weak_reset}"
    bap_text_out "${_bap_env_timestamp}"
    bap_text_out "${bap_text_weak_full}]╛\n"
}


bap_output_ps1_interim() {
    bap_text_out_centered $bap_ps1_max_width "╶─╼━╾─╴"
}


bap_output_ps1_header() {
    # ---
    # Left corner of the line...
    # ---
    local ps1_entry_raw="╒"
    local -i width_curr=${#ps1_entry_raw}
    bap_text_out "${bap_text_weak_full}${ps1_entry_raw}"

    # ---
    # OS info.
    # ---
    if [[ -n "$bap_ps1_os" ]]; then
        ps1_entry_raw=" ${bap_ps1_os} ═"
        width_curr=$(($width_curr + ${#ps1_entry_raw}))

        bap_text_out "${bap_text_weak_reset}${bap_text_fmt_dim} ${bap_ps1_os} ${bap_text_weak_full}═"
    fi

    # ---
    # Optional CHROOT info.
    # ---
    if [[ -n "${bap_ps1_chroot}" ]]; then
        ps1_entry_raw="${bap_ps1_chroot} ="
        width_curr=$(($width_curr + ${#ps1_entry_raw}))

        bap_text_out "${bap_text_weak_reset}${bap_text_fmt_dim}${bap_ps1_chroot} ${bap_text_weak_full}="
    fi

    # ---
    # User info.
    # ---
    bap_env_ident
    if [[ -n "${_bap_env_ident}" ]]; then
        ps1_entry_raw=" ${_bap_env_ident} "
        width_curr=$(($width_curr + ${#ps1_entry_raw}))

        bap_text_out " ${bap_text_weak_reset}"
        bap_text_out "${bap_text_fmt_green}${_bap_env_ident}${bap_text_fmt_reset}"
        bap_text_out " ${bap_text_weak_full}"
    fi

    # ---
    # MIDDLE FILL SHOULD GO HERE!!!
    # ---
    # But first we need to figure out how wide the right-hand side stuff is...

    # ---
    # Right-Hand Side Stuff.
    # ---
    if $bap_show_ip_in_header ; then
        ps1_entry_raw="${_bap_env_ip_addr_private}╱${_bap_env_ip_addr_public}"
        width_curr=$(($width_curr + ${#ps1_entry_raw}))
    fi

    ps1_entry_raw="╕"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    # ---
    # MIDDLE FILL DOES GO HERE!!!
    # ---
    bap_terminal_width $bap_ps1_max_width
    bap_text_out_fill $(($_bap_terminal_width - $width_curr)) ═

    # ---
    # IP Address.
    # ---

    if $bap_show_ip_in_header ; then
        # Let it still be dim?
        # Then have to add print props back in after reset to keep it dim.
        bap_text_out "${bap_text_weak_reset}"
        bap_text_out "${_bap_env_ip_addr_private}"
        bap_text_out "${bap_text_weak_full}╱${bap_text_weak_reset}${bap_text_fmt_dim}"
        bap_text_out "${_bap_env_ip_addr_public}"
    fi

    # ---
    # Final Corner.
    # ---
    bap_text_out "${bap_text_weak_full}╕\n"
}


bap_output_ps1_subheader() {
    # Do we even have a subheader line?
    if ! $bap_show_ip_in_subheader; then
        # It's fine not to have one.
        return 0
    fi

    # ---
    # Left corner of the line...
    # ---
    local ps1_entry_raw="├"
    local -i width_curr=${#ps1_entry_raw}
    bap_text_out "${bap_text_weak_full}${ps1_entry_raw}"

    # ---
    # Right-Hand Side Stuff.
    # ---
    # None Currently.

    # ---
    # MIDDLE FILL SHOULD GO HERE!!!
    # ---
    # But first we need to figure out how wide the right-hand side stuff is...

    # ---
    # Right-Hand Side Stuff.
    # ---
    if $bap_show_ip_in_subheader ; then
        ps1_entry_raw="${_bap_env_ip_addr_private}╱${_bap_env_ip_addr_public}"
        width_curr=$(($width_curr + ${#ps1_entry_raw}))
    fi

    ps1_entry_raw="┤"
    width_curr=$(($width_curr + ${#ps1_entry_raw}))

    # ---
    # MIDDLE FILL DOES GO HERE!!!
    # ---
    bap_terminal_width $bap_ps1_max_width
    bap_text_out_fill $(($_bap_terminal_width - $width_curr)) ─

    # ---
    # IP Address.
    # ---

    if $bap_show_ip_in_subheader ; then
        # Let it still be dim?
        # Then have to add print props back in after reset to keep it dim.
        bap_text_out "${bap_text_weak_reset}"
        bap_text_out "${_bap_env_ip_addr_private}"
        bap_text_out "${bap_text_weak_full}╱${bap_text_weak_reset}${bap_text_fmt_dim}"
        bap_text_out "${_bap_env_ip_addr_public}"
    fi

    # ---
    # Final Corner.
    # ---
    bap_text_out "${bap_text_weak_full}┤\n"
}


bap_output_ps1_dir() {
    # ------------------------------
    # Are we in a version control repository?
    # ------------------------------
    if bap_path_in_vc "$PWD"; then
        # ---
        # Directory
        # ---
        # Can't use "\w" when we're called every prompt and are explicitly echoing the dir.

        # Split into root, relative if in a VC dir.
        local ps1_path_parent="$(bap_pretty_path "$(dirname "$_bap_path_root_vc")")"
        local ps1_path_repo="$(basename "$_bap_path_root_vc")"
        local ps1_path_rel="$(bap_pretty_path_relative "$_bap_path_root_vc" "$PWD")"

        # Repo's root path one color & relative path a second color.
        bap_text_out "${bap_text_weak_full}├┬ ${bap_text_weak_reset}"
        bap_text_out "${bap_text_fmt_blue}${ps1_path_parent}/"
        # Still blue but also underline the repo name.
        bap_text_out "${bap_text_fmt_underline}${ps1_path_repo}${bap_text_fmt_underline_reset}"
        # Recolor "/relative/path/in/repo" to "version control color".
        bap_text_out "${bap_text_fmt_yellow}/${ps1_path_rel}${bap_text_fmt_reset}\n"

        # ---
        # Version Control
        # ---
        bap_text_out "${bap_text_weak_full}│└─${bap_text_weak_reset}"
        bap_text_out "${bap_text_fmt_yellow}$(bap_ps1_vc_prompt)${bap_text_fmt_reset}\n"
    else
        # ---
        # Directory Only
        # ---

        # All one color.
        bap_text_out "${bap_text_weak_full}├─ ${bap_text_weak_reset}${bap_text_fmt_blue}$(bap_pretty_pwd)${bap_text_fmt_reset}\n"
    fi
}


bap_output_ps1_prompt() {
    # Any additional info to show before prompt?
    if $bap_show_tier; then
        if bap_env_dev_tier ; then
            bap_ps1_prompt_info="$_bap_env_dev_tier"
            bap_ps2_prompt_info="$_bap_env_dev_tier"
        else
            bap_ps1_prompt_info=""
            bap_ps2_prompt_info=""
        fi
    fi

    # Final PS1 line: The Prompt.
    bap_text_out "${bap_text_weak_full}└┤${bap_text_weak_reset}"
    bap_text_out "${bap_ps1_prompt_info}${bap_ps1_prompt_symbol}"
}


bap_output_ps1() {
    # ------------------------------
    # Build & output the prompt:
    # ------------------------------
    # Only output footer/interim if we actually ran a previous command.
    if bap_cmd_ran $_bap_timer_pid; then
        bap_output_ps1_footer
        bap_output_ps1_interim
    fi

    bap_output_ps1_header
    bap_output_ps1_subheader

    bap_output_ps1_dir

    bap_output_ps1_prompt

    # ------------------------------
    # Clean-Up
    # ------------------------------
    bap_timer_clear $_bap_timer_pid
    _bap_cmd_ran=false
}



# ------------------------------------------------------------------------------
# PS2: Used as prompt for incomplete commands.
# ------------------------------------------------------------------------------
bap_output_ps2() {
    # ------------------------------
    # Set up PS2 variable
    # ------------------------------
    # PS1:
    #             "..."
    #             "${bap_text_weak_full}└┤${bap_text_weak_reset}"
    bap_text_out "${bap_text_weak_full} │${bap_text_weak_reset}"
    #             "${bap_ps1_prompt_info}${bap_ps1_prompt_symbol}"
    bap_text_out "${bap_ps2_prompt_info}${bap_ps2_prompt_symbol}"
}


# ------------------------------------------------------------------------------
# PS3: Used as prompt for `select` statements.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# PS4: Prefix for statements during execution trace (`set -x`).
#   - Printed multiple times if multiple levels of indirection.
#   - Default is: "+ "
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Set-Up
# ------------------------------------------------------------------------------

bap_prompt_setup() {
    # Use `bap` for PS0 (run just before a command is run).
    PS0='$(bap_output_ps0)'

    # Use `bap` for PS1/PS2 (command prompt & continuation prompt).
    PS1='$(bap_output_ps1)'
    PS2='$(bap_output_ps2)'

    # Don't have right now but could:
    # PS3='$(bap_output_ps3)' # `select` prompt
    # PS4='$(bap_output_ps4)' # execution trace prefix

    # Hook `bap` into Bash's PROMPT_COMMAND variable.
    PROMPT_COMMAND=bap_prompt_command
}


# ------------------------------------------------------------------------------
# Prompt Builder
# ------------------------------------------------------------------------------

bap_prompt_command() {
    # ------------------------------
    # First: Exit Code
    # ------------------------------
    # This needs to be first in order to get the last command's exit code.
    local -i exit_code=$?

    # ------------------------------
    # Exit Code Status
    # ------------------------------

    if [[ $exit_code -eq 0 ]]; then
        bap_prev_cmd_exit_status=""
    else
        bap_prev_cmd_exit_status="${exit_code}"
    fi

    # bap_prev_cmd="$BASH_COMMAND"
}
