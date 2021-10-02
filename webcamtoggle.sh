#!/bin/bash
ID=$(lsusb | grep -i webcam | cut -d ':' -f3 | cut -c 1-4)
CONFIG=$( grep $ID /sys/bus/usb/devices/*/idProduct | sed s/idProduct:$ID//g )bConfigurationValue

if ( lsmod | grep uvcvideo &> /dev/null ); then
    pkexec sh -c 'echo 0 > '$CONFIG'; sleep 2; rmmod -f uvcvideo'
    notify-send -a "Webcam" "Webcam off"
else
    pkexec sh -c 'echo 1 > '$CONFIG'; modprobe uvcvideo'
    notify-send -a "Webcam" "Webcam on"
fi

