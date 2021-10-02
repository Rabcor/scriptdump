#!/bin/sh
#Purpose of script is to toggle between speaker and headphones when headphones are plugged in. Also changes easyeffects/pulseffects preset if it is installed.
#Run with '-e' argument to only apply the appropriate easyeffects/pulseeffects preset (may be good to run on startup)

#For ALSA
CARD=0

if ( amixer | grep Speaker ); then
    SPEAKER_CHANNEL=Speaker
else
    SPEAKER_CHANNEL=Front
fi

#For PulseAudio and PipeWire-Pulse
#To list all available ports: pactl list sinks | awk '/Ports:/{f=1;next} /Active Port:/{f=0} f' | cut -d ':' -f1
HEADPHONE_PORT=analog-output-headphones
SPEAKER_PORT=analog-output-speaker

#For EasyEffects; Output & Input presets when using speaker
SPEAKER_EE_PRESET="Laptop Speaker"
SPEAKER_EE_I_PRESET="NR+EC"
#For EasyEffects; Output & Input presets when using headphones
HEADPHONE_EE_PRESET="HB-Mid"
HEADPHONE_EE_I_PRESET="NR"

#For PulseEffects; Output & Input presets when using speaker
SPEAKER_PE_PRESET="$SPEAKER_EE_PRESET"
SPEAKER_PE_I_PRESET="$SPEAKER_EE_I_PRESET"
#For PulseEffects; Output & Input presets when using headphones
HEADPHONE_PE_PRESET="$HEADPHONE_EE_PRESET"
HEADPHONE_PE_I_PRESET="$HEADPHONE_EE_I_PRESET"

if [ "$1" = "-b" ]; then
    echo Enabling both headphones and speakers.
    notify-send -a "Audio" "Playing on both headphones and speakers."
    amixer -c $CARD set Headphone on > /dev/null
    amixer -c $CARD set $SPEAKER_CHANNEL on > /dev/null
    exit
fi

#Switch between headphones and speakers.
if ( amixer -c $CARD sget $SPEAKER_CHANNEL | grep off > /dev/null ) && [ "$1" != "-e" ]; then
    echo Enabling speakers and disabling headphones.
    notify-send -a "Audio" "Switched to speakers."
    amixer -c $CARD set $SPEAKER_CHANNEL on > /dev/null
    amixer -c $CARD set Headphone off > /dev/null
elif [ "$1" != "-e" ]; then
    echo Enabling headphones and disabling speakers.
    notify-send -a "Audio" "Switched to headphones."
    amixer -c $CARD set Headphone on > /dev/null
    amixer -c $CARD set $SPEAKER_CHANNEL off > /dev/null
fi

#PulseAudio & PipeWire Below
if [ -f /usr/bin/pactl ]; then
    SINK=$(pactl info | grep "Default Sink:" -m1 | cut -d ':' -f2) #To list all available sink names: pactl list sinks | grep Name
    ACTIVE_PORT=$(pactl list sinks | grep "Active Port:" | cut -d ':' -f2)
    if [ $ACTIVE_PORT = $SPEAKER_PORT ] && [ "$1" != "-e" ]; then
        pactl set-sink-port $SINK $HEADPHONE_PORT
    elif [  $ACTIVE_PORT = $HEADPHONE_PORT ] && [ "$1" != "-e" ]; then
        pactl set-sink-port $SINK $SPEAKER_PORT
    fi
    pactl set-sink-mute $SINK no    # Unmute after switching because for some reason whenever you switch ports it automatically mutes on some PCs.
else
    echo /usr/bin/pactl not found, this script will not work with PulseAudio or PipeWire-Pulse without pactl, ignoring...
fi

#EasyEffects Below
if ( pgrep easyeffects ); then
    if ( amixer -c $CARD sget $SPEAKER_CHANNEL | grep off > /dev/null ); then
        echo Setting easyeffects preset to $HEADPHONE_EE_PRESET and input preset to $HEADPHONE_EE_I_PRESET
        easyeffects -l "$HEADPHONE_EE_PRESET"
        easyeffects -l "$HEADPHONE_EE_I_PRESET"
    else
        echo Setting easyeffects preset to $SPEAKER_EE_PRESET and input preset to $SPEAKER_EE_I_PRESET
        easyeffects -l "$SPEAKER_EE_PRESET"
        easyeffects -l "$SPEAKER_EE_I_PRESET"
    fi
    pactl set-sink-mute easyeffects_sink no # Ensure EasyEffects is not muted (Fixes the possible issue of the system muting EasyEffects and user not noticing.
    pactl set-source-mute easyeffects_source no # Ditto
fi

#PulseEffects Legacy Below
if ( pgrep pulseeffects ); then
    if ( amixer -c $CARD sget $SPEAKER_CHANNEL | grep off > /dev/null ); then
        echo Setting pulseeffects preset to $HEADPHONE_PE_PRESET and input preset to $HEADPHONE_PE_I_PRESET
        pulseeffects -l "$HEADPHONE_PE_PRESET"
        pulseeffects -l "$HEADPHONE_PE_I_PRESET"
    else
        echo Setting pulseeffects preset to $SPEAKER_PE_PRESET and input preset to $SPEAKER_PE_I_PRESET
        pulseeffects -l "$SPEAKER_PE_PRESET"
        pulseeffects -l "$SPEAKER_PE_I_PRESET"
    fi
    pactl set-sink-mute PulseEffects_apps no # Ensure PulseEffects is not muted (Fixes the possible issue of the system muting PulseEffects and user not noticing.
    #pactl set-source-mute PulseEffects_mic no # Ditto | PulseEffects input plugins not working with PulseAudio 15.0+
fi
