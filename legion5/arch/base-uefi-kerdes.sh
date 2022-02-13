#!/bin/sh
# 
install_dialog() {
	DIALOG_RESULT=$(dialog --clear --stdout --backtitle "Arch Telepítés" --no-shadow "$@" 2>/dev/null)
}
install_dialog --title "Arch Install" --inputbox "Kérlek válasz, hogy maradsz az alap telepítésnél(I) vagy sajátot hozol létre(N)? I/N\n" 8 60
install="$DIALOG_RESULT"

hostname="Aporka"
user="volo"
pswroot="pheiL9ge."
pswuser="Faz9.x8_"
machine="legion5" # g5 t470 legion5 rpi4
country="Hungary"
cpu="amd-ucode" # intel-ucode amd-ucode
dgraphics="nvidia" # none nvidia amd discrete grafikus kártya
igraphics="amd" # none intel amd integrated grafikus kártya
gitpath="/mnt/github/arch/$machine/arch/setup"
ltime="Europe/Budapest" # Argentina/BuenosAires
editor="nvim" # nano vim nvim ed
packages="netctl dialog net-tools links gptfdisk networkmanager pwgen mc ntfs-3g $cpu reflector $editor"

if [ $install = "N" ]
then
	install_dialog --title "Hostname" --inputbox "Mi legyen a gép neve?\n" 8 60
	hostname="$DIALOG_RESULT"
	install_dialog --title "User name" --inputbox "Mi legyen a felhasználó neve?\n" 8 60
	user="$DIALOG_RESULT"
	install_dialog --title "Root password" --inputbox "Mi legyen a root jelszava?\n" 8 60
	pswroot="$DIALOG_RESULT"
	
	install_dialog --title "User password" --inputbox "Mi legyen a felhasználó jelszava?\n" 8 60
	pswuser="$DIALOG_RESULT"

	install_dialog --title "Machine" --inputbox "Mi a gép könyvtárának a neve ahol a beállítások találhatóak?\n" 8 60
	machine="$DIALOG_RESULT"

	install_dialog --title "Country" --inputbox "Mi az ország? pl: Hungary\n" 8 60
	country="$DIALOG_RESULT"

	install_dialog --title "CPUID" --inputbox "Milyen processzorod van? pl:intel/amd\n" 8 60
	cpu="$DIALOG_RESULT-ucode"

	install_dialog --title "Discrete Graphics" --inputbox "Van discrete vidókártyád? pl:I/N\n" 8 60
	if [ $DIALOG_RESULT = "I" ]
	then
		install_dialog --title "Discrete Graphics" --inputbox "Milyen? pl: nvidia/amd\n" 8 60
		dgraphics="$DIALOG_RESULT"
	else
		dgraphics="none"
	fi
	install_dialog --title "Integrated graphics" --inputbox "Van integrált videókártyád? pl:I/N\n" 8 60
	if [ $DIALOG_RESULT = "I" ]
	then	
		install_dialog --title "Integrated graphics" --inputbox "Milyen integrált videókártyád van? pl:intel/amd\n" 8 60
		igraphics="$DIALOG_RESULT"
	else
		igraphics="none"
	fi

	install_dialog --title "GitPath" --inputbox "Adsz meg git útvonalat? pl: I/N\n" 8 60
	if [ $DIALOG_RESULT = "I" ]
	then
		install_dialog --title "GitPath" --inputbox "Mi a git könyvtár elérési útja?\n" 8 60
		gitpath="$DIALOG_RESULT"
	fi

	install_dialog --title "Local time" --inputbox "Mi a helyi időzóna? pl: Europe/Budapest\n" 8 60
	ltime="$DIALOG_RESULT"

	install_dialog --title "Editor" --inputbox "Milyen szövegszerkesztőt szeretnél használni konzolban? pl: vim/nano/ed/nvim\n" 8 60
	editor="$DIALOG_RESULT"
fi
# End config


ln -sf /usr/share/zoneinfo/$ltime /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
sed -i '284s/.//' /etc/locale.gen
locale-gen
cat > /etc/locale.conf << EOF
LANG=hu_HU.UTF-8
LC_COLLATE=C
EOF
cat > /etc/vconsole.conf << EOF
KEYMAP=hu
FONT=lat2-16
EOF
echo $hostname >> /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 $hostname.localdomain $hostname
EOF
if [ $dgraphics = "nvidia" ]
then
	pacman -S nvidia nvdidia_modeset nvidia_uvm nvidia_drm
fi

if [ $igraphics = "amd" ]
then
	pacman -S xf86-video-amdgpu
fi
cat $gitpath/mkinitcpio.conf > /etc/mkinitcpio.conf
mkinitcpio -P
pacman -S grub efibootmgr grub-btrfs
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch --recheck
cat $gitpath/grub > /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S --needed $packages
grub-mkconfig -o /boot/grub/grub.cfg
echo root:$pswroot | chpasswd
useradd -m -g users -G wheel,video -s /bin/bash $user
cat $gitpath/pacman.conf > /etc/pacman.conf
mv /etc/pacman.d/mirrorlist >> /etc/pacman.d/mirrorlist.old
reflector -c $country -a 6 --sort rate --save /etc/pacman.d/mirrorlist
systemctl enable NetworkManager
echo "$user ALL=(ALL) ALL" >> /etc/sudoers.d/$user
printf "\e[1;32mVégeztünk! Gépeld be, hogy cd / && exit && swapoff -a && umount -R /mnt && reboot.\e[0m"

