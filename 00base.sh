#!/bin/sh
#BEGIN Config
disk1="/dev/nvme0n1" # /dev/vnme0n1
disk15="/dev/nvme0n1p6" # /boot // disk1 => első lemez, 15 => első lemez ötödik partíció
disk16="/dev/nvme0n1p7" # /
disk2="/dev/sda" # /dev/sda
disk21="/dev/nvme0n1p5" # /dev/sda1 //disk2 => második lemez, 21 => második lemez első partíció
deditor="nano" # a telepítési lemez alapértelmezett szerkesztője, nem ez lesz a rendszered alapértelmezettje
editor="nano" # vim neovim nano // ez lesz a végleges rendszer alapértelmezettje
kernel="linux-lts linux-zen" # linux linux-zen linux-lts // elég akár egy kernel-t is megadni, de ez soha nem lehet üres
filesystem="btrfs" # ext4 btrfs
formaz="none" # sda none // sda formázása
table="gdisk" # fdisk gdisk cfdisk cgdisk
# END Config
#iwctl
$table $disk1
if [ $formaz = "sda" ]
then
	gdisk $disk2
fi
if [ $filesystem = "btrfs" ]
then
	mkfs.vfat -F32 $disk15
	mkfs.btrfs -f $disk16
	mount $disk16 /mnt
	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@var_log
	btrfs subvolume create /mnt/@snapshots
	btrfs subvolume create /mnt/@swap

	umount /mnt
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@ $disk16 /mnt
	mkdir -p /mnt/{boot,home,var/log,.snapshots,swap}
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@home $disk16 /mnt/home
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@var_log $disk16 /mnt/var/log
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@snapshots $disk16 /mnt/.snapshots
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@swap $disk16 /mnt/swap

	mount $disk15 /mnt/boot

	if [ $disk21 = "nvme0n1p5" ]
	then
		mkdir /mnt/sda && mount $disk21 /mnt/sda
	fi

	# swapfile
	cd /mnt/swap
	truncate -s 0 ./swapfile
	chmod 600 ./swapfile
	chattr +C ./swapfile
	btrfs property set ./swapfile compression none

	dd if=/dev/zero of=/mnt/swap/swapfile bs=1G count=8 status=progress
	mkswap /mnt/swap/swapfile
	swapon /mnt/swap/swapfile
else
	mkfs.vfat -F32 $disk15
	mkfs.ext4 $disk16
	mkfs.ext4 $disk17
	mount $disk16 /mnt
	mkdir /mnt/boot && mount $disk15 /mnt/boot
	mkdir /mnt/home && mount $disk17 /mnt/home
	if [ $disk21 = "nvme0n1p5" ]
	then
		mkdir /mnt/sda && mount $disk21 /mnt/sda
	fi

	dd if=/dev/zero of=/mnt/swapfile bs=1G count=8 status=progress
	chmod 600 /mnt/swapfile
	mkswap /mnt/swapfile
	swapon /mnt/swapfile

fi
	

#pacstrap /mnt base base-devel linux-zen linux-lts linux-firmware neovim btrfs-progs git
if [ $filesystem = "btrfs" ]
then
	pacstrap /mnt base base-devel $kernel linux-firmware $editor btrfs-progs git
else
	pacstrap /mnt base base-devel $kernel linux-firmware $editor git
fi
genfstab -U /mnt >> /mnt/etc/fstab
$deditor /mnt/etc/fstab
arch-chroot /mnt
