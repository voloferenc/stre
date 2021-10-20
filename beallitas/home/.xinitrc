#!/bin/sh
xrdb ~/.Xresources
#xrandr --setprovideroutputsource modesetting NVIDIA-0
#xrandr --output eDP-1-1 --scale 1x1 --mode 1920x1080 --dpi 96
#dbus-update-activation-environment --systemd DISPLAY
#/usr/bin/start-pulseaudio-x11
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
#export QT_QPA_PLATFORMTHEME="qt5ct"
#udiskie -2 &
exec dbus-launch i3
#exec startkde
