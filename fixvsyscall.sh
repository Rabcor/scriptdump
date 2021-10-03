#!/bin/sh
# Some anti-cheat software (notably in League of Legends) needs abi.vsyscall32 to be disabled. This script re-enables it, and is meant to be used as a post-exit script.

STATE=$(sysctl -n abi.vsyscall32)
EXEC=pkexec # Options: pkexec, kdesu, sudo(no gui!)

if [ "$STATE" = "0" ]; then
    $EXEC sh -c 'sysctl -w abi.vsyscall32=1'
    echo "abi.vsyscall32 = $STATE"
fi

