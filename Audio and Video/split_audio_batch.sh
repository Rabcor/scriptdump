#!/bin/sh
#Designed so you can copy text (for instance from a youtube vid description or comment) that has timestamps for songs in file and automatically dividing the file down to files for each individual song.
#Depends on accompanying script: split_audio.sh

mainscript=/home/$USER/Scripts/split_audio.sh
mainfile=$(echo $1 | sed 's: :\ :g')
timefile=$(echo $2 | sed 's: :\ :g')
pass=0

if [ -z "$2" ]; then
    echo "Usage: split_audio [file] [file]
Example: split_audio_batch file.mp3 timestamps.txt
    Divides file.mp3 to multiple files using the names and timestamps from timestamps.txt"
    exit
fi

while read line; do
    fileout=$(echo $pass. $songname | tr -s ' ')
    if [ $pass -eq 0 ]; then
        last=00:00
        songname=$(echo $line | grep -zoe [A-z\ ])
    else
        if [ $(echo $line | grep -oP '\d{2}\:\d{2}\:\d{2}') ]; then
            current=$(echo $line | grep -oP '\d{2}\:\d{2}\:\d{2}')
            songname=$(echo $line | grep -zoe [A-z\ ])
        elif [ $(echo $line | grep -oP '\d{2}\:\d{2}') ]; then
            current=$(echo $line | grep -oP '\d{2}\:\d{2}')
            songname=$(echo $line | grep -zoe [A-z\ ])
        elif [ $(echo $line | grep -oP '\d\:\d{2}') ]; then
            current=$(echo $line | grep -oP '\d:\d{2}')
            songname=$(echo $line | grep -zoe [A-z\ ])
        fi
        echo $mainscript "$mainfile" $last $current "$fileout"
        $mainscript "$mainfile" $last $current "$fileout"
        last=$current
    fi
    pass=$(($pass + 1))
done < $timefile

fileout=$(echo $pass. $songname | tr -s ' ')
echo $mainscript "$mainfile" $last $current "$fileout"
$mainscript "$mainfile" $last end "$fileout"
