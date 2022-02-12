#!/bin/sh
#BEGIN Config
disk1="/dev/nvme0n1" # /dev/vnme0n1
disk15="/dev/nvme0n1p5" # /boot // disk1 => első lemez, 15 => első lemez ötödik partíció
disk16="/dev/nvme0n1p6" # /
disk21="/dev/sda1" # /dev/sda1 //disk2 => második lemez, 21 => második lemez első partíció
editor="vim" # vim nano
# END Config
iwctl
gdisk $disk1
mkfs.vfat -F32 $disk15
mkfs.btrfs -f $disk16
mount $disk16 /mnt
btrfs subvolume create /mnt/@
btrfs subvolbtrfs create /mnt/@home
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
mkdir /mnt/sda
mount $disk21 /mnt/sda

# swapfile
cd /mnt/swap
truncate -s 0 ./swapfile
chmod 600 ./swapfile
chattr +C ./swapfile
btrfs property set ./swapfile compression none

dd if=/dev/zero of=/mnt/swap/swapfile bs=1G count=8 status=progress
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

pacstrap /mnt base base-devel linux-zen linux-lts linux-firmware neovim btrfs-progs git
genfstab -U /mnt >> /mnt/etc/fstab
$editor /mnt/etc/fstab
arch-chroot /mnt
