#!/bin/bash
# BEGIN Config
user="stre"
init="systemd" # systemd dinit openrc runit s6 suite66
desktop="kde" # kde i3 xfce gnome
machine="legion5" # legion5 g5 rpi4 t450
gitpath="/mnt/doksi/stre-main/$machine/arch"
ulb_dir="/usr/local/bin/"
uls_dir="/usr/local/sbin/"
dm="sddm" # sddm lightdm gdm
editor="nano" # nvim vim nano ed none
optimus="none" # optimus-manager none
graphics="intel" # nvidia intel amd none
filesystem="btrfs" # ext4 btrfs
units="cronie NetworkManager NetworkManager-dispatcher cups-browsed haveged bluetooth fstrim.timer $dm"
laptop="nem" # igen nem
drive="ssd" # ssd hdd
tmpfile="/tmp/packages"
# END Config
# A többit a program autómatikusan megoldja

sudo timedatectl set-ntp true
sudo hwclock --systohc

pacman -S --needed $(cat $gitpath/$desktop)

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# beállítás átmásolása

# etc
if [ $graphics = "nvidia" ]
then
	cp -a $gitpath/beallitas/etc/X11/* /etc/X11/
else
	cp -a $gitpath/beallitas/etc/X11/* /etc/X11/
	rm -rf /etc/X11/xorg.conf.d/20-nvidia.conf
fi

if [ $drive = "ssd" ]
then
	cp -a $gitpath/beallitas/etc/cron.daily/* /etc/cron.daily/
fi

if [ $filesystem = "btrfs" ]
then
	cp -a $gitpath/beallitas/etc/default/* /etc/default/
	cp -a $gitpath/beallitas/etc/grub.d/* /etc/grub.d/
fi

cp -a $gitpath/beallitas/etc/modprobe.d/* /etc/modprobe.d/
cp -a $gitpath/beallitas/etc/modules-load.d /etc/
if [ $graphics = "nvidia" ]
then
	cp -a $gitpath/beallitas/etc/pacman.d /etc/
else
	cp -a $gitpath/beallitas/etc/pacman.d /etc/
	rm -rf /etc/pacman.d/hooks/nvidia.hook
fi

if [ $filesystem = "ext4" ]
then
	rm -rf /etc/pacman.d/hooks/101-snap.hook
fi

if [ $init != "systemd" ]
then
	rm -rf /etc/pacman.d/hooks/100-systemd-boot.hook
fi

# cp -a $gitpath/beallitas/etc/sysctl.d /etc/
cp -a $gitpath/beallitas/etc/udev/* /etc/udev/
cp -a $gitpath/beallitas/etc/makepkg.conf /etc/
# cp -a $gitpath/beallitas/etc/ntp.conf /etc/
cp -a $gitpath/beallitas/etc/resolv.conf.head /etc/

if [ $laptop = "igen" ]
then
	cp -a $gitpath/beallitas/etc/tlp.conf /etc/
fi

# root
cp -a $gitpath/beallitas/root/.config /root/
cp -a $gitpath/beallitas/root/.bashrc /root/
cp -a $gitpath/beallitas/root/.zshrc /root/



# usr/local

cp -a $gitpath/beallitas/$ulb_dir/* /$ulb_dir/
cp -a $gitpath/beallitas/$uls_dir/* /$uls_dir/

# packages
pacman -U $gitpath/csomagok/i3/yay-bin*

if [ $editor = "nvim"]
then
	pacman -U $gitpath/csomagok/i3/vim-plug*
elif [ $editor = "vim" ]
then
	pacman -U $gitpath/csomagok/i3/vim-plug*
fi

if [ $optimus = "optimus-manager" ]
then
	pacman -U $gitpath/csomagok/i3/optimus-manager*
	cp -a $gitpath/beallitas/etc/optimus-manager/* /etc/optimus-manager/
else
	rm -rf /etc/pacman.d/hooks/optimus.hook
fi

#sysctl -p /etc/sysctl.d/99-sysctl.conf

gpasswd -a $user vboxusers

if [ $init = "systemd" ]
then
	systemctl enable $units
else
	rc-update add $units default
fi

chsh -s /bin/zsh
printf "\e[1;32mElkészült a grafikus felület feltelepítése és konfigurálása! Kérlek most felhaszálőként lépj be és add ki a következő /mnt/sda/home/./git.sh parancsot majd lépj be a github/arch/$machine/arch könyvtárba és futtasd a 03base-user.sh-t.\e[0m"
