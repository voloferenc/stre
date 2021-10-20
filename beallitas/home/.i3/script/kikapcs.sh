#!/usr/bin/sh

if ( xrandr | grep "HDMI1 connected"); then
    xrandr --output LVDS1 --mode 1366x768 --output HDMI1 --mode 1920x1080 --right-of LVDS1 && xrandr --output HDMI1 --off && systemctl poweroff
else
    systemctl poweroff
fi
