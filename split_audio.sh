#!/bin/sh
#Use ffmpeg to split an audio file by duration

filename=$(echo $1 | sed 's: :\ :g' | rev | cut -d '.' -f2- | rev) #Filename without extension
format=$(echo $1 | rev | cut -d '.' -f1 | rev) #File extension
fileout=$(echo $filename\_out.$format | sed 's: :\ :g') #Output file name
timestart=$2
timestop=$3

if [ $3 ]; then
    timestart=$2
    timestop=$3
elif [ $2 ]; then
    timestart=00:00:00
    timestop=$2
else
    echo "Usage: split_audio [file] [time arg 1] [time arg 2]
Example: split_audio file.mp3 00:20:00
    Creates file with content from start to minute 20
Example: split_audio file.mp3 20:00 30:00
    Creates file with content from minute 20 to minute 30
Example: split_audio file.mp3 20:00 end
    Creates file with content from minute 20 to file end
"
exit
fi

if [ "$4" ]; then
    fileout=$(echo $4.$format | sed 's: :\ :g')
fi

if [ "$3" == "end" ]; then
    ffmpeg -ss $timestart -i "$filename.$format" -c:a copy -async 1 "$fileout"
else
    ffmpeg -ss $timestart -to $timestop -i "$filename.$format" -c:a copy -async 1 "$fileout"
fi
