#!/bin/sh
#Screencapture via ffmpeg and nvenc.
#Accepts one argument for a preset (web, hq) but by default uses the default configuration below.
#Issues: Audio is desynced (maybe 2-2.5 seconds behind)
#        File sizes are big (I remember finding a way to make files really small but lost my original script and forgot how)
#        A bit choppy playback (might just be when gpu is stressed during recording)


#############################
#Prevent duplicate instances#
#############################
if pidof -x -o $$ $(basename "$0") > /dev/null; then
echo "Screencast is already running, closing all instances..."
pkill ffmpeg
exit
fi

##################
#Default Settings#
##################

format=mp4
filename=`date +%d%m%y-%H%M%S`
location=/home/rabcor/Videos

#Audio
adrv=pulse
channels=2
ainput=$(pactl list sinks | grep  Name | grep -v -e "alsa" | cut -d ':' -f2)
acodec=aac

#Video
screencap_module=x11grab
screen=":0.0"
fps=60
resolution=1920x1080
vcodec=h264_nvenc

#Quality
quality="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -qmin 20 -rc:v vbr_minqp -cq:v 29 -preset:v p7"

#Tweaks
pixfmt=yuv444p
colors="-color_range tv -colorspace bt2020_ncl -color_primaries bt709 -color_trc gamma22"
filters="hue=h=-3:s=0.98, eq=gamma=0.98:contrast=0.99"


#########
#Presets#
#########
if [ "$1" = "web" ]; then     #Web Preset
format=mp4

#Video
fps=60
vcodec=h264_nvenc

#Quality
quality="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -qmin 20 -rc:v vbr_minqp -cq:v 29 -preset:v p7"

#Tweaks
pixfmt=yuv444p
colors="-color_range tv -colorspace bt2020_ncl -color_primaries bt709 -color_trc gamma22"
filters="hue=h=-3:s=0.98, eq=gamma=0.98:contrast=0.99"

elif [ "$1" = "hq" ]; then      #High Quality Preset
format=mkv

#Video
fps=60
vcodec=hevc_nvenc

#Quality
quality="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -qmin 17 -rc:v vbr_minqp -cq:v 22 -preset:v p7"

#Tweaks
pixfmt=gbrp
colors=""
filters="eq="
fi


#################
#Run the command#
#################
ffmpeg -f $adrv -ac $channels -i  $ainput -c:a $acodec -video_size $resolution -framerate $fps -f $screencap_module -i $screen -c:v $vcodec $quality -pix_fmt $pixfmt $colors -vf "$filters" $location/$filename.$format
