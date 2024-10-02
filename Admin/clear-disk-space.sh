#!/bin/sh

#Get Filesystem Size
size=$(df -h / | grep G | cut -d 'G' -f3 | sed 's: ::g')

#Commands:
sudo pacman -Scc
sudo pacman -Rns $(pacman -Qtdq)
sudo journalctl --flush --vacuum-files=5
rm -rf $HOME/.cache/yay/*
rm -rf $HOME/.cache/mozilla/firefox/*
rm -rf $HOME/.cache/chromium/Default/*
rm -rf $HOME/.cache/nvidia/GLCache/*
rm -rf $HOME/.cache/winetricks/*
rm -rf $HOME/.cache/unity3dcache/*
gio trash --empty

#Results
sizea=$(df -h / | grep G | cut -d 'G' -f3 | sed 's: ::g')

echo "Free space before: $size GB
Free space after: $sizea GB"
