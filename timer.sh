#!/bin/bash
#A countdown timer that synchronizes with the system clock to ensure accuracy (prevent drift).
#Note: The sleep command is not actually necessary, it just drastically improves efficiency by slowing down the loop to ease the CPU load involved in running the timer.

alarm=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga

if [ -z "$1" ]; then
    echo "Usage: [Seconds] [Minutes] [Hours]"
    exit
fi

minutes=$(( ( $2 + 0 ) * 60 ))
hours=$(( ( $3 + 0 ) * 60 * 60 ))
seconds=$(( $1 + $hours + $minutes))
final=$(($(date +%s) + $seconds))

while (( $(date +%s) < $final )); do                  #While conditions ensure that the timer won't stop until the time has actually passed according to the clock.
    sleep 0.9988 | echo -ne "Time Remaining: $(( $seconds / 60 / 60 )):$(( $seconds / 60 % 60)):$(( $seconds % 60 ))\033[0K\r" #0.9988 to compensate for drift, on my CPU it eliminated drift tested over 5 hours.
    $((seconds--)) &> /dev/null

    timer=$(($final - $(date +%s)))
    if (( $seconds != $timer )); then                 #Sync countdown with the timer in case of drift. (This obsoletes the sleep 0.9988 command since the countdown timer is now correcting, left it in anyways though.)
        if (( $seconds > $timer )); then
            $((seconds--)) &> /dev/null
        elif (( $seconds < $timer )); then
            $((seconds++)) &> /dev/null
        fi
    fi
done

playsound "$alarm"
