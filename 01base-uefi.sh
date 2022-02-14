#!/bin/sh
# BEGIN Config 
hostname="ArchStre"
user="stre"
pswroot="poba7880"
pswuser="puba5680"
machine="legion5" # beállításokhoz kell
country="Hungary"
cpu="intel-ucode" # intel-ucode amd-ucode
#discrete grafikus kártya
dgraphics="none" # nvidia amd
#integrált grafikus kártya
igraphics="i915" # i915 amdgpu
gitpath="/mnt/github/stre/$machine/arch/setup"
ltime="Europe/Budapest" # Argentina/BuenosAires
key="hu_HU.UTF-8"
keymap="hu" # hu en de es
editor="nano" # nano vim neovim ed
packages="netctl dialog net-tools links gptfdisk networkmanager mc ntfs-3g $cpu reflector $editor"
#kernel_header="linux-lts-headers linux-zen-headers" # linux-lts-headers linux-zen-headers linux-headers
filesystem="btrfs" # btrfs ext4
# END Config

echo "Időzóna beállítása"
ln -sf /usr/share/zoneinfo/$ltime /etc/localtime
hwclock --systohc
echo "Nyelv beállítása"
sed -i '177s/.//' /etc/locale.gen
sed -i '284s/.//' /etc/locale.gen
locale-gen
cat > /etc/locale.conf << EOF
LANG=$key
LC_COLLATE=C
EOF
if [ $keymap = "hu" ]
then
	cat > /etc/vconsole.conf << EOF
KEYMAP=$keymap
FONT=lat2-16
EOF
else
	cat > /etc/vconsole.conf << EOF
KEYMAP=$keymap
EOF
fi
echo "Hostname beállítása"
echo $hostname > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $hostname.localdomain $hostname
EOF

#cat $gitpath/mkinitcpio.conf > /etc/mkinitcpio.conf
echo "Initramfs létrehozása"
# sed -i 's/^HOOKS.*/HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"/' /etc/mkinitcpio.conf
if [ $dgraphics = "nvidia" ]
then
	sed -i "s/^MODULES.*/MODULES=($igraphics) # nvidia nvidia_modeset nvidia_uvm nvidia_drm)/" /etc/mkinitcpio.conf
else
	sed -i "s/^MODULES.*/MODULES=($igraphics)/" /etc/mkinitcpio.conf
fi
if [ $filesystem = "btrfs" ]
then
	sed -i 's/^HOOKS.*/HOOKS="base udev autodetect modconf block resume btrfs filesystems keyboard"/' /etc/mkinitcpio.conf
else
	sed -i 's/^HOOKS.*/HOOKS="base udev autodetect modconf block resume filesystems keyboard fsck"/' /etc/mkinitcpio.conf
fi
mkinitcpio -P
echo "Grub telepítése"
pacman -S --needed --noconfirm grub efibootmgr grub-btrfs
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --recheck
cat $gitpath/grub > /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
echo "Csomagok telepítése"
pacman -S --needed --noconfirm $packages
grub-mkconfig -o /boot/grub/grub.cfg
echo "root jelszó beállítása és $user felhasználó létrehozása majd jelszavának beállítása"
echo root:$pswroot | chpasswd
useradd -m -g users -G wheel,video -s /bin/bash $user
echo $user:$pswuser | chpasswd
echo "Pacman beállítása és csomagadatbázisának frissítése"
cat $gitpath/pacman.conf > /etc/pacman.conf
cat /etc/pacman.d/mirrorlist >> /etc/pacman.d/mirrorlist.old
pacman -Syu --noconfirm
reflector -c $country -a 6 --sort rate --save /etc/pacman.d/mirrorlist
systemctl enable NetworkManager
echo "$user hozzáadása a sudoers fájlhoz"
echo "$user ALL=(ALL) ALL" >> /etc/sudoers.d/$user
printf "\e[1;32mVégeztünk! Gépeld be, hogy exit && cd / && swapoff -a && umount -R /mnt && reboot.\e[0m"
