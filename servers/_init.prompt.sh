# Source this file.


# ------------------------------------------------------------------------------
# Settings, etc.
# ------------------------------------------------------------------------------

bap_path_root="${_dc_path_script}/.."

source "${bap_path_root}/_text.sh"

# Show what Environment Tier we're on just before cmd prompt & continuation prompt:
bap_show_tier=true
bap_ps1_prompt_info="$dc_tier_short"
bap_ps2_prompt_info="$dc_tier_short"

# The user/host can be really long so split the IPs to another line to allow room.
bap_show_ip_in_header=false
bap_show_ip_in_subheader=true

# Have remote servers be purpleish.
bap_setting_text_weak_color="${bap_text_fmt_purple}"
bap_setting_text_weak_dim=false


# ------------------------------------------------------------------------------
# Prompt (PS1) Section of "~/.bashrc"
# ------------------------------------------------------------------------------
# Don't want to insert our stuff in the middle where it should go, so just
# copy/paste what Ubuntu does and tweak it?

# ------------------------------
# From Ubuntu 20.04
# ------------------------------

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

    # ------------------------------
    # OVERRIDE the prompt
    # ------------------------------
    if [[ -f "${bap_path_root}/init.sh" ]]; then
        source "${bap_path_root}/init.sh"
    fi
    # ------------------------------
    # /OVERRIDE
    # ------------------------------

else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
