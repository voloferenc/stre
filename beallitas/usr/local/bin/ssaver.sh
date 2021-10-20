#!/bin/sh

if [ $1 -eq 1 ]
then
    xset +dpms && xset s 600 600 && notify-send "10 perc"
elif [ $1 -eq 3 ]
then
    xset -dpms && xset s 1800 1800 && notify-send "30 perc"
elif [ $1 -eq 6 ]
then
    xset -dpms && xset s 3600 3600 && notify-send "1 óra"
elif [ $1 -eq 9 ]
then
    xset -dpms && xset s 10800 10800 && notify-send "3 óra"
elif [ $1 -eq 0 ]
then
    xset dpms force standby
fi
