#!/usr/bin/sh

if ( xrandr | grep "HDMI-0 connected"); then
    xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 1920x1080 --right-of eDP-1-1 && xrandr --output HDMI-0 --off && systemctl reboot
else
    systemctl reboot
fi
