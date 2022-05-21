#!/bin/sh

preset=$1
filename=$(echo $2 | rev | cut -d '.' -f2- | rev) #Filename without extension, whitespace not supported.
format=$(echo $2 | rev | cut -d '.' -f1 | rev) #File extension
fileout=$(echo $filename\_$preset.$format) #Output file name
pixfmt=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1 $filename.$format 2>/dev/null | cut -d '=' -f2)

codec=libx265 #Recommend libx265

width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=nw=1 $filename.$format 2>/dev/null | cut -d '=' -f2)
height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nw=1 $filename.$format 2>/dev/null | cut -d '=' -f2)
scalewidth=1920
scaleheight=1080

crfc="-crf"

#Preset selection
if [ "$preset" = "fast" ]; then
    CRF=18
    SPEED=veryfast
elif [ "$preset" = "fast-smaller" ]; then
    CRF=23
    SPEED=veryfast
elif [ "$preset" = "fast-extreme" ]; then
    CRF=28
    SPEED=veryfast
elif [ "$preset" = "hq" ]; then
    CRF=18
    SPEED=slow
elif [ "$preset" = "hq-smaller" ]; then
    CRF=23
    SPEED=slow
elif [ "$preset" = "hq-extreme" ]; then
    CRF=28
    SPEED=slow
elif [ "$preset" = "vhq" ]; then
    CRF=14
    SPEED=slow
elif [ "$preset" = "nv" ]; then
    #Nvidia specific settings, run: ffmpeg -hide_banner -h encoder=hevc_nvenc
    codec=hevc_nvenc
    CRF=17
    SPEED=p7    #profiles p1-p7 are fastest (lowest quality) to slowest (highest quality) p7 is highest. Nvenc is so fast there's never really a reason not to use p7.
    crfc="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -rc:v constqp -qp"    #Command adjustment for nvenc
elif [ "$preset" = "nv-smaller" ]; then
    codec=hevc_nvenc
    CRF=24
    SPEED=p7
    crfc="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -rc:v constqp -qp"
elif [ "$preset" = "nv-extreme" ]; then
    #Still uses vbr rather than qp because when qp is over 24 it's quality goes to shit. Vbr tends to provide better quality files but the compression is worse than qp.
    codec=hevc_nvenc
    CRF=32
    SPEED=p7
    crfc="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -b:v 0 -rc:v vbr -cq:v"
elif [ "$preset" = "nv2" ]; then
    codec=hevc_nvenc
    CRF=18
    SPEED=p7
    crfc="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -qmin 17 -rc:v vbr_minqp -cq:v"
elif [ "$preset" = "nv2-x" ]; then
    codec=hevc_nvenc
    CRF=28
    SPEED=p7
    crfc="-tier high -spatial-aq 1 -multipass fullres -tune:v hq -qmin 17 -rc:v vbr_minqp -cq:v"
else
    echo "Usage: vcompress [preset] [file]
Presets:
	nv2            Decent compression, great quality, super fast encoding
	nv2-x          Good compression, good quality, super fast encoding

	nv             Bad compression, fantastic quality, super fast encoding
	nv-smaller     High compression, decent quality, super fast encoding
	nv-extreme     High compression, ok quality, super fast encoding

	fast           Good compression, good quality, fast encoding
	fast-smaller   Higher compression, ok quality, fast encoding
	fast-extreme   Extreme compression, low quality, fast encoding

	hq             Decent copmression, fantastic quality, slow encoding
	hq-smaller     High compression, great quality, really slow encoding
	hq-extreme     Extreme compression, ok quality, slow encoding

	vhq            Worst compression, best quality, slowest encoding
Notes:
    vhq is almost lossless but it's got bad compression.
    hq is second highest quality but compression is twice as good as vhq.
    nv is third highest quality but compression is almost as bad as vhq.
    nv presets generally have much worse compression to quality ratios than the others.
    nv2-x is about the same quality & compression as the fast preset.
    hq-smaller provides the best middle ground in quality vs compression of the software presets.
    sometimes to get a file to a desired size you'll end up having to compromise quality, time or both."


	exit
fi

if [ -z "$2" ]; then                #Sanity check
    echo "Error: No file specified
Format: vcompress [preset] [file]"
    exit
fi

#If video resolution is higher than a set amount, prompt for downscaling.
if [ $width -gt $scalewidth ] || [ $height -gt $scaleheight ]; then
    echo "File resolution is $width x $height, would you like to downscale it? [Y/n]"
    read REPLY
    if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ]; then
        if [ $width -gt $height ]; then
            scalecmd="-vf scale=$scalewidth:-1"
            modifier=$(expr $width / $scalewidth)
            scaleheight=$(expr $height / $modifier)
            echo "Downscaling to $scalewidth x $scaleheight"
            #if [[ $codec = *nvenc* ]]; then
            #    scalecmd="-vf scale_cuda=$scalewidth:-1"
            #fi
        else
            scalecmd="-vf scale=-1:$scaleheight"
            modifier=$(expr $height / $scaleheight)
            scalewidth=$(expr $width / $modifier)
            echo "Downscaling to $scalewidth x $scaleheight"
            #if [[ $codec = *nvenc* ]]; then
            #    scalecmd="-vf scale_cuda=-1:$scaleheight"
            #fi
        fi

    fi
fi

#Confirmation prompt.
echo "
Command: ffmpeg -threads 6 -movflags +faststart $scalecmd -pix_fmt $pixfmt -c:a copy -c:v $codec $crfc $CRF -preset:v $SPEED $fileout -i $filename.$format

Encoding $filename.$format to $fileout with the $preset preset...

Continue? [Y/n]"
read REPLY
if [ "$REPLY" = "Y" ] || [ "$REPLY" = "y" ]; then
    REPLY=""
    echo "Encoding..."
else
    exit
fi

#Encoding command.
ffmpeg -threads 6 -movflags +faststart $scalecmd -pix_fmt $pixfmt -c:a copy -c:v $codec $crfc $CRF -preset:v $SPEED $fileout -i $filename.$format

#Overwrite prompt (non-destructive)
echo "Would you like to overwrite the original file ($filename.$format)? [Yes/no]"
read REPLY
REPLY=$(echo $REPLY | tr '[:upper:]' '[:lower:]')
if [ "$REPLY" = "yes" ]; then
    echo "Moving $filename.$format to trash.
renaming $fileout to $filename.$format"
    gio trash $filename.$format     #Original file goes to trash
    mv $fileout $filename.$format   #New file renamed to replace original
else
    exit
fi
