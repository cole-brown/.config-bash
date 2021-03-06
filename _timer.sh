# Originally from https://stackoverflow.com/a/58140726


# ------------------------------------------------------------------------------
# Timer Variables
# ------------------------------------------------------------------------------

_bap_timer_duration=""

_bap_timer_pid=""


# ------------------------------------------------------------------------------
# Traps
# ------------------------------------------------------------------------------

bap_timer_trap_exit () {
    # Clean up the timestamp in shared memory.
    rm "/dev/shm/${USER}.bap.time.${_bap_timer_pid}"
}


# ------------------------------------------------------------------------------
# Timer Functions
# ------------------------------------------------------------------------------

bap_timer_clear () {
    local pid="$1"
    if [[ -z "$pid" ]]; then
        return 1
    fi

    # Places the epoch time in ns into shared memory.
    echo "-1" >"/dev/shm/${USER}.bap.time.${pid}"
    # echo "-1 put in?"
    # cat "/dev/shm/${USER}.bap.time.${pid}"
}


bap_timer_valid() {
    local pid="$1"
    if [[ -z "$pid" ]]; then
        return 1
    fi

    if [[ ! -f "/dev/shm/${USER}.bap.time.${pid}" ]]; then
        return 2
    else
        local start="$(cat /dev/shm/${USER}.bap.time.${pid})"
        if [[ -z "$start" ]] || [[ "$start" = -* ]]; then
            # "-1" is what we put to clear it in ~bap_timer_clear~, so if it's negative, ignore it.
            return 3
        fi
    fi

    return 0
}


# TODO: Maybe use this for timing command durations? "hh:mm:ss.mmm"
#   - Currently just "s.mmm"
bap_timer_round () {
    local seconds="$1"
    # Rounds a number to 3 decimal places.
    # echo m=${seconds}";h=0.5;scale=4;t=1000;if(m<0) h=-0.5;a=m*t+h;scale=3;a/t;" | bc
    # _bap_timer_duration="$(echo m=${seconds}";h=0.5;scale=4;t=1000;if(m<0) h=-0.5;a=m*t+h;scale=3;a/t;" | bc)"

    _bap_timer_duration="$(cat <<END_MATHS | bc
millisec=${seconds};
roundhalf=0.5;
scale=4;
millipersec=1000;
if(millisec<0) roundhalf=-0.5;
roundedmillisec=millisec*millipersec+roundhalf;
scale=3;
rounded=roundedmillisec/millipersec;
if(rounded<1) print 0;
rounded
END_MATHS
)"
}


bap_timer_start () {
    local pid="$1"
    if [[ -z "$pid" ]]; then
        return 1
    fi

    # Places the epoch time in ns into shared memory.
    date +%s.%N >"/dev/shm/${USER}.bap.time.${pid}"
}


bap_timer_stop () {
    local pid="$1"
    if [[ -z "$pid" ]]; then
        return 1
    fi

    if [[ -f "/dev/shm/${USER}.bap.time.${pid}" ]]; then
        _bap_timer_duration=""

        # Reads stored epoch time, subtracts from current, and outputs.
        local start="$(cat /dev/shm/${USER}.bap.time.${pid})"
        if [[ -z "$start" ]] || [[ "$start" = -* ]]; then
            # "-1" is what we put to clear it in ~bap_timer_clear~, so if it's negative, ignore it.
            return 2
        fi

        local end="$(date +%s.%N)"
        bap_timer_round $(echo $(eval echo "$end - $start") | bc)
    fi
}


bap_timer_setup() {
    export _bap_timer_pid=$BASHPID
    trap bap_timer_trap_exit EXIT
}
