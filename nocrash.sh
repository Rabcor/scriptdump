#!/bin/sh
#A simple script to make a program restart itself if it crashes or is turned off.

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ]; then
    echo "Usage: nocrash.sh [command] [args]

This script will make a program restart itself everytime it crashes or is closed."
    exit
fi

while true; do
    $@
done
