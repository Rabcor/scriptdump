#!/bin/sh
# Syntax:
#   mountiso.sh /path/to/iso
#   mountiso.sh -u
# Optionally depends on fuseiso. (If you fail to mount an iso, I suggest trying with fuseiso, a lot of files that don't work with mount work with fuseiso.)

MOUNTPOINT=/run/media/$USER/iso

if [ "$1" = "-u" ]; then
    echo Unmounting iso at $MOUNTPOINT
    sudo umount $MOUNTPOINT
    exit
elif [ "$1" = "" ]; then
    echo Path to image file missing, exiting.
    exit
fi

if [ -d "$MOUNTPOINT" ]; then
    echo Mountpoint $MOUNTPOINT found
else
    echo Mountpoint $MOUNTPOINT not found, creating...
    sudo mkdir $MOUNTPOINT
    sudo chown "$USER" $MOUNTPOINT
fi

if [ $(find $MOUNTPOINT -maxdepth 0 -empty) ]; then
    echo Mountpoint $MOUNTPOINT confirmed to be empty, continuing...
else
    echo Mountpoint $MOUNTPOINT is not empty, attempting to unmount...
    sudo umount $MOUNTPOINT
    if [ $(find $MOUNTPOINT -maxdepth 0 -empty) ]; then
        echo Mountpoint $MOUNTPOINT confirmed to be empty, continuing...
    else
        echo ERROR: Failed to unmount image at $MOUNTPOINT
        echo Mountpoint not empty, exiting...
        exit
    fi
fi

if [ -f /usr/bin/fuseiso ]; then
    echo Mounting $@ to $MOUNTPOINT with fuseiso.
    fuseiso "$@" $MOUNTPOINT
else
    echo Mounting $@ to $MOUNTPOINT with mount command.
    sudo mount -o loop -t iso9660 "$@" $MOUNTPOINT
fi
