#!/bin/sh
INDEX=$(pacmd list-sinks | grep "* index:" | cut -d ' ' -f 5-)

pactl set-sink-volume $INDEX +10% && killall -SIGUSR1 i3status
