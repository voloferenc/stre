#!/bin/sh
SCREEN_DIR=~/Képek/screenshot

if [ -d ~/Képek/screenshot ]
then
    echo "screenshot létrehozás..."    
else
    echo "screenshot könyvtár nem létezik, létrehozás"
    echo "screenshot..."
    mkdir $SCREEN_DIR
fi

filename=`date +%Y-%m-%d_%H:%M:%S`.jpg
import -window root "$SCREEN_DIR/$filename" && notify-send -t 5 "$filename"
echo "Screenshot kész!"
