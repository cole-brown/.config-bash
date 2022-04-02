# Originally from https://stackoverflow.com/a/58140726


# ------------------------------------------------------------------------------
# Timer Variables
# ------------------------------------------------------------------------------

_bap_timer_duration=""

_bap_timer_pid=""


# ------------------------------------------------------------------------------
# Timer Functions
# ------------------------------------------------------------------------------

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

    # Places the epoch time in ns into shared memory.
    date +%s.%N >"/dev/shm/${USER}.bap.time.${pid}"

    # TODO: WTF? always same start/end/duration? >.<
    # echo "/dev/shm/${USER}.bap.time.${pid}"
    # cat "/dev/shm/${USER}.bap.time.${pid}"
}


bap_timer_stop () {
    local pid="$1"

    _bap_timer_duration=""
    # Reads stored epoch time, subtracts from current, and outputs.
    local end="$(date +%s.%N)"
    local start="$(cat /dev/shm/${USER}.bap.time.${pid})"

    # TODO: WTF? always same start/end/duration? >.<
    # echo "start: $start"
    # echo "end:   $end"
    # echo "dur:   $(eval echo "$end - $start")"
    # echo "dur:   $(echo $(eval echo "$end - $start") | bc)"

    bap_timer_round $(echo $(eval echo "$end - $start") | bc)
}


bap_timer_setup() {
    export _bap_timer_pid=$BASHPID
}
