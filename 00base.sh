#!/bin/sh
exec > /output.txt 2>&1
#BEGIN Config
disk1="/dev/nvme0n1" # /dev/vnme0n1
delDiskNumbers=(6 7) # partíciók száma amit törölni szeretnél, ez a lista lehet üres is ha nem szeretnél törölni
mkDiskNumbers=(6 7) # a létrehozni kívánt partíciók sorszáma
mkDiskSize=(+512M 0) # a partíciók mérete első a /boot, második a /, harmadik /home, a megabájtot így adod meg pl: +512M a gigabyteot pedig így pl: +20G a 0 a teljes maradék lemez felhasználását jelenti, a mkDiskSize elemeinak a száma meg kell, hogy egyezzen a mkDiskNumbers elemeinek a számával
diskType=(ef00 8300 8200) # ef00->efi 8300->linux filesystem 8200->swap pl így nézzen ki: "ef00 8200 8300" a sorrend fontos ha van swap
filesystem="btrfs" # ext4 btrfs
disk2="/dev/nvme0n1p5" # /dev/sda1 // ez a változó csak a programban az összehasonlítás miatt kell, ha nem egyezik az alatta levővel akkor nem fogja csatolni a külső partíciót
disk21="/dev/nvme0n1p5" # /dev/sda1 //disk2 => második lemez, 21 => második lemez első partíció
disk2name="doksi" # a csatolni kívánt adat partíció neve pl doksi vagy sda stb
deditor="nano" # a telepítési lemez alapértelmezett szerkesztője, nem ez lesz a rendszered alapértelmezettje
editor="nano" # vim neovim nano // ez lesz a végleges rendszer alapértelmezettje
kernel="linux-lts linux-zen" # linux linux-zen linux-lts // elég akár egy kernel-t is megadni, de ez soha nem lehet üres
formaz="none" # sda none // sda formázása
table="gdisk" # fdisk gdisk cfdisk cgdisk
# END Config
#####

umount /sda
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

# megvizsgálja, hogy kell e törölni partíciót ha üres delDiskNumbers akkor nem töröl semmit
if [ ${#delDiskNumbers[*]} -gt 0 ]
then
	for value in ${delDiskNumbers[*]}; do
		sgdisk $disk1 -d $value
	done
fi

# itt kezdődik a lemez formázása
# ha diskNubmer nagyobb mint kettő akkor ő autómatikusan swap-nak fogja formázni
# ha nem akkor az első ef00 lesz a másidik pedig linux filesystem 8300
counter=0
diskNubmer=${#mkDiskNumbers[*]}
for value in ${mkDiskNumbers[*]}; do
	if [ $counter -eq 0 ]
	then
		sgdisk $disk1 -n=$value:0:${mkDiskSize[counter]} -t=$value:${diskType[0]}
	elif [ $diskNubmer -gt 2 ]
	then
		sgdisk $disk1 -n=$value:0:${mkDiskSize[counter]} -t=$value:${diskType[2]}
		let diskNubmer=0
	else
		sgdisk $disk1 -n=$value:0:${mkDiskSize[counter]} -t=$value:${diskType[1]}
	fi
	let counter++
done

if [ $filesystem = "btrfs" ]
then
	mkfs.vfat -F32 $bootdev
	mkfs.btrfs -f $rootdev
	mount $rootdev /mnt
	btrfs subvolume create /mnt/@
	btrfs subvolume create /mnt/@home
	btrfs subvolume create /mnt/@var_log
	btrfs subvolume create /mnt/@snapshots
	btrfs subvolume create /mnt/@swap

	umount /mnt
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@ $rootdev /mnt
	mkdir -p /mnt/{boot,home,var/log,.snapshots,swap}
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@home $rootdev /mnt/home
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@var_log $rootdev /mnt/var/log
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@snapshots $rootdev /mnt/.snapshots
	mount -o noatime,compress=zstd,ssd,discard=async,space_cache=v2,subvol=@swap $rootdev /mnt/swap

	mount $bootdev /mnt/boot

	if [ $disk21 = $disk2 ]
	then
		mkdir /mnt/mnt/$disk2name && mount $disk21 /mnt/mnt/$disk2name
	fi

	# swapfile
	# csak akkor csinálja meg ha nem 3 partíciót adtunk meg neki

	if [ ${#mkDiskNumbers} -lt 3 ]
	then
		cd /mnt/swap
		truncate -s 0 ./swapfile
		chmod 600 ./swapfile
		chattr +C ./swapfile
		btrfs property set ./swapfile compression none

		dd if=/dev/zero of=/mnt/swap/swapfile bs=1G count=8 status=progress
		mkswap /mnt/swap/swapfile
		swapon /mnt/swap/swapfile
	else
		mkswap $swapdev
		swapon $swapdev
	fi
else
	mkfs.vfat -F32 $bootdev
	mkfs.ext4 $rootdev
	mkfs.ext4 $homedev
	mount $rootdev /mnt
	mkdir /mnt/boot && mount $bootdev /mnt/boot
	mkdir /mnt/home && mount $homedev /mnt/home
	if [ $disk21 = $disk2 ]
	then
		mkdir /mnt/mnt/$disk2name && mount $disk21 /mnt/mnt/$disk2name
	fi

	# swapfile
	# csak akkor csinálja meg ha nem 3 partíciót adtunk meg neki
	if [ ${#mkDiskNumbers} -gt 3 ]
	then

		dd if=/dev/zero of=/mnt/swapfile bs=1G count=8 status=progress
		chmod 600 /mnt/swapfile
		mkswap /mnt/swapfile
		swapon /mnt/swapfile
	else
		mkswap $swapdev
		swapon $swapdev
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

genfstab -U /mnt >> /mnt/etc/fstab
blkid -s PARTUUID -o value $rootdev >> /mnt/diskuuid
$deditor /mnt/etc/fstab
mkdir /mnt/mnt/github
cd /mnt/mnt/github && git clone https://github.com/voloferenc/stre
cd /
#arch-chroot /mnt /mnt/github/stre/./01base-uefi.sh
arch-chroot /mnt
printf "\e[1;32mVégeztünk! Gépeld be, hogy reboot.\e[0m"
