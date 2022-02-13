#!/bin/sh
INDEX=$(cat ~/.i3/script/hangindex)

if [ $INDEX -eq 0 ]; then
    rm -rf .config/pulse
    pulseaudio -k
    pulseaudio --start
    echo 1 > ~/.i3/script/hangindex
fi

CURRENT_PROFILE=$(pacmd list-cards | grep "active profile" | cut -d ' ' -f 3-)

if [ $CURRENT_PROFILE = "<output:hdmi-stereo>" ]; then
    pacmd set-card-profile 0 "output:analog-stereo" && notify-send -t 5 analog-stereo
else
    pacmd set-card-profile 0 "output:hdmi-stereo" && notify-send -t 5 hdmi-stereo
fi
