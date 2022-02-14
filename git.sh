#!/bin/sh

pacman -Sy
pacman -S --noconfirm git
echo "Mi legyen a könyvtár pl: /mnt/github vagy /home/user/github, teljes útvonalat adj meg!"
read directory
mkdir -p ${directory}
cd ${directory}
#cd /home/volo/github
git clone https://github.com/voloferenc/stre
