#!/bin/bash

killall sbxkb
nyelv=`setxkbmap -query | awk '/layout/{print $2}'`

if [ $nyelv = "hu" ]
then
    `setxkbmap -layout us`
else
    `setxkbmap -layout hu`
fi

sbxkb &
