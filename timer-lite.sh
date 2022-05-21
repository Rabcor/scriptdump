#!/bin/bash
#Warning: The countdown is not 100% accurate (on my pc it is accurate over 5 hours at least), to compensate for drift i made the sleep command faster, results may vary based on CPU.
alarm=/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga

minutes=$(( ( $2 + 0 ) * 60 ))
hours=$(( ( $3 + 0 ) * 60 * 60 ))
seconds=$(( $1 + $hours + $minutes))

while (( $seconds > 0 )); do
    sleep 0.9988 | echo -ne "Countdown: $(( $seconds / 60 / 60 )):$(( $seconds / 60 % 60)):$(( $seconds % 60 ))\033[0K\r" #0.9988 to compensate for drift, 0.998 was too fast, 0.999 too slow. Results may differ on another CPU.
    $((seconds--)) &> /dev/null
done

playsound "$alarm"
