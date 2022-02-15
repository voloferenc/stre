#!/bin/sh

pacman -Sy
pacman -S --needed --noconfirm git wget
#echo "Mi legyen a könyvtár pl: /mnt/github vagy /home/user/github, teljes útvonalat adj meg!"
#read directory
directory="/github"
mkdir -p ${directory}
cd ${directory}
#cd /home/volo/github
#https://raw.githubusercontent.com/voloferenc/stre/main/git.sh
#chmod +x git.sh
wget -c https://raw.githubusercontent.com/voloferenc/stre/main/00base.sh
chmod +x 00base.sh
./00base.sh
