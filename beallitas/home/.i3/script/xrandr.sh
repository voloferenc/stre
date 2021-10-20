#!/bin/sh

if (xrandr | grep "HDMI-0 connected"); then
    if (cat ~/.i3/script/hdmi | grep "HDMI left"); then
        xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 3840x2160 --left-of eDP-1-1
    elif (cat ~/.i3/script/hdmi | grep "HDMI right"); then
        xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 3840x2160 --right-of eDP-1-1
    elif (cat ~/.i3/script/hdmi | grep "HDMI on"); then
        #xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 1920x1080 --right-of eDP-1-1 && 
        xrandr --output eDP-1-1 --off && time 1
    else
        xranrd --output HDMI-0 --off
    fi
fi
