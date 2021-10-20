#!/bin/sh

case "$1" in
    1)
        xrandr --output HDMI-0 --scale 1x1
        ;;
    0)
        xrandr --output HDMI-0 --scale 0.75x0.75
        ;;
    *)
        echo "Wrong number"
        exit 2
esac
