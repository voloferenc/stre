#!/bin/sh
#exec > /output.txt 2>&1
#BEGIN Config
disk1="/dev/nvme0n1" # /dev/vnme0n1
bootdev="/dev/nvme0n1p6" # /boot // disk1 => első lemez, 15 => első lemez ötödik partíció
swapdev="/dev/sdd3" # swap
rootdev="/dev/nvme0n1p7" # /
homedev="/dev/nvme0n1p7" # /home
homedevsda="/dev/nvme0n1p5" # /dev/sda1 ennek meg kell egyeznie a homedevsda1-el mert ha nem akkor nem csatolja a külső meghajtót
homedevsda1="/dev/nvme0n1p5" # /dev/sda1 //homedevsda => második lemez, 21 => második lemez első partíció
secDiskName="doksi" # a külső csatolni kívánt partíció neve pl doksi, adat stb
deditor="nano" # a telepítési lemez alapértelmezett szerkesztője, nem ez lesz a rendszered alapértelmezettje
editor="nano" # vim neovim nano // ez lesz a végleges rendszer alapértelmezettje
kernel="linux-lts linux-zen" # linux linux-zen linux-lts // elég akár egy kernel-t is megadni, de ez soha nem lehet üres
filesystem="btrfs" # ext4 btrfs
swap="file" # file swap none // swapfile vagy swap partíció létrehozása vagy egyik sem
swapsize="2" # a swap file mérete GB-ban
partSda="none" # igen none // sda particionalsa
typeSda="ext4" # ext4 btrfs // sda partíció formázása
gitDirectory="/mnt/mnt/github" # github könyvtára
# END Config
#####

diskname="${disk1}p"
bootdev=${diskname}${mkDiskNumbers[0]}
if [ ${#mkDiskNumbers} -gt 2 ]
then
	swapdev=${diskname}${mkDiskNumbers[1]}
	rootdev=${diskname}${mkDiskNumbers[2]}
	homedev=${diskname}${mkDiskNumbers[3]}
else
	rootdev=${diskname}${mkDiskNumbers[1]}
	homedev=${diskname}${mkDiskNumbers[2]}
fi
####
#iwctl
gdisk $disk1
if [ $partSda = "igen" ]
then
	umount /sda
	gdisk $partSda
fi

if [ $filesystem = "btrfs" ]
then
	mkfs.vfat -F32 $bootdev
	mkfs.btrfs -f $rootdev
	mount $rootdev /mnt
	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@var_log
	btrfs subvolume create /mnt/@snapshots
	if [ $swap = "file" ]
    	then
		btrfs subvolume create /mnt/@swap
	fi

	umount /mnt
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@ $rootdev /mnt
	mkdir -p /mnt/{boot,home,var/log,.snapshots,swap}
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@home $rootdev /mnt/home
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@var_log $rootdev /mnt/var/log
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@snapshots $rootdev /mnt/.snapshots
	if [ $swap = "file" ]
	then
		mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@swap $rootdev /mnt/swap
	fi

	mount $bootdev /mnt/boot

	mkdir /mnt/mnt/$secDiskName && mount $homedevsda1 /mnt/mnt/$secDiskName

    if [ $swap = "file" ]
    then
		# swapfile
		cd /mnt/swap
		truncate -s 0 ./swapfile
		chmod 600 ./swapfile
		chattr +C ./swapfile
		btrfs property set ./swapfile compression none

		dd if=/dev/zero of=/mnt/swap/swapfile bs=1G count=$swapsize status=progress
		mkswap /mnt/swap/swapfile
		swapon /mnt/swap/swapfile
  	elif [ $swap = "swap" ]
	then
		mkswap $swapdev
		swapon $swapdev
	else
		echo "nincs swap"
	fi

else
	mkfs.vfat -F32 $bootdev
	mkfs.ext4 $rootdev
	mkfs.ext4 $homedev
	mount $rootdev /mnt
	mkdir /mnt/boot && mount $bootdev /mnt/boot
	mkdir /mnt/home && mount $homedev /mnt/home
	if [ $homedevsda1 = $homedevsda]
	then
        	if [ $partSda = "igen" ]
        	then
            		mkfs.$typeSda $homedevsda1
        	fi
		mkdir /mnt/mnt/$secDiskName && mount $homedevsda1 /mnt/mnt/$secDiskName
	fi

    	if [ $swap = "file" ]
    	then
        	dd if=/dev/zero of=/mnt/swapfile bs=1G count=$swapsize status=progress
        	chmod 600 /mnt/swapfile
        	mkswap /mnt/swapfile
        	swapon /mnt/swapfile
	elif [ $swap = "swap" ]
	then
        	mkswap $swapdev
        	swapon $swapdev
    	else
        	echo "nincs swap"
    	fi
fi
	
# pacman keyring frissites
pacman-key --init
pacman-key --populate archlinux

#pacstrap /mnt base base-devel linux-zen linux-lts linux-firmware neovim btrfs-progs git
if [ $filesystem = "btrfs" ]
then
	pacstrap /mnt base base-devel $kernel linux-firmware $editor btrfs-progs git
else
	pacstrap /mnt base base-devel $kernel linux-firmware $editor git
fi

if [ $partSda = "none" ]
then
	umount /sda
fi
genfstab -U /mnt >> /mnt/etc/fstab
blkid -s PARTUUID -o value $rootdev >> /mnt/diskuuid
$deditor /mnt/etc/fstab
mkdir $gitDirectory
cd $gitDirectory && git clone https://github.com/voloferenc/stre
cd /
arch-chroot /mnt
