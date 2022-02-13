#!/bin/sh

HDMI_STATUS=`cat ~/.config/i3/script/hangindex`

if [ $HDMI_STATUS = "0" ]
then
	# a számot úgy derítettem ki, hogy 'pactl list' után a két utolsó Card szám, pl Card #44 vagy Card #42
	pactl set-card-profile 42 output:hdmi-stereo
	pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo
	echo 1 > ~/.config/i3/script/hangindex
else
	pactl set-card-profile 44 output:analog-stereo
	pactl set-default-sink alsa_output.pci-0000_05_00.6.analog-stereo
	echo 0 > ~/.config/i3/script/hangindex
fi
