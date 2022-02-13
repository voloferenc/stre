#!/bin/sh

if (xrandr | grep "HDMI-0 connected"); then
    if (cat ~/.config/i3/script/hdmi | grep "HDMI left"); then
        #xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 3840x2160 --left-of eDP-1-1
        autorandr --load left
    elif (cat ~/.config/i3/script/hdmi | grep "HDMI right"); then
        #xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 3840x2160 --right-of eDP-1-1
        autorandr --load right
    elif (cat ~/.config/i3/script/hdmi | grep "HDMI on"); then
        #xrandr --output eDP-1-1 --mode 1920x1080 --output HDMI-0 --mode 1920x1080 --right-of eDP-1-1 && 
        #xrandr --output eDP-1-1 --off && time 1
        autorandr --load lg
    else
        #xranrd --output HDMI-0 --off
        autorandr --load l5
    fi
fi
