#!/bin/sh

pacman -Sy
pacman -S --noconfirm git
echo "Mi legyen a könyvtár pl: /mnt/github vagy /home/user/github, teljes útvonalat adj meg!"
read directory
mkdir -p ${directory}
cd ${directory}
#cd /home/volo/github
wget -c https://github.com/voloferenc/stre/blob/main/git.sh
chmod +x git.sh
wget -c https://github.com/voloferenc/stre/blob/main/00base.sh
chmod +x 00base.sh
./00base.sh
