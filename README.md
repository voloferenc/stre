######################################
# Arch Linux telepítése és beállítása
######################################

# A billentyű magyarra állítása
    loadkeys hu

# Lemez Partícionállása (UEFI) BTRFS esetén elég csak 3 partíciót léltrehozni, 1. uefi 2. swap 3. / 
    gdisk /dev/sda
    
 Partíciók kilistázása
 
    -> p
    
 Partíciók törlése
 
    -> O
    
 EFI létrehozása 512 MB, ahová a kettőspont után nem írtam semmit elég Entert ütni
 
    -> n
    Partition number (1-128, default 1):
    First sector (34-98989128281, default = 2048) or {+-}-size{KMGTP}:
    Last sector (* stb), defaults = *) or {+-}size{KMGTP}:  +512M
    Current type is 8300 (Linux filesystem)
    Hex code or GUID (L to show codes, Enter = 8300): ef00
    
 Root (/) partíció lérethozása
 
    -> n
    Partition number (1-128, default 2):
    First sector (34-98989128281, default = 2048) or {+-}-size{KMGTP}:
    Last sector (* stb), defaults = *) or {+-}size{KMGTP}:  +50G
    Current type is 8300 (Linux filesystem)
    Hex code or GUID (L to show codes, Enter = 8300):
    
 Home (/home) partíció létrehozása
 
    -> n
    Partition number (1-128, default 3):
    First sector (34-98989128281, default = 2048) or {+-}-size{KMGTP}:
    Last sector (* stb), defaults = *) or {+-}size{KMGTP}:
    Current type is 8300 (Linux filesystem)
    Hex code or GUID (L to show codes, Enter = 8300):

Ha swap is kell akkor

    -> n
    Partition number (1-128, default 4):
    First sector (34-98989128281, default = 2048) or {+-}-size{KMGTP}:
    Last sector (* stb), defaults = *) or {+-}size{KMGTP}:  +16G
    Current type is 8300 (Linux filesystem)
    Hex code or GUID (L to show codes, Enter = 8300): 8200
    
Kiírjuk a változtatásokat

    -> w
    
Ha csak ki akarunk lépni akkor

    -> q

# Partícionálás és csatolás
    mkfs.vfat -F32 /dev/sdb1
    mkfs.ext4 /dev/sdb2
    mkfs.ext4 /dev/sdb3
    
    mount /dev/sdb2 /mnt
    mkdir /mnt/boot && mount /dev/sdb1 /mnt/boot
    mkdir /mnt/home && mount /dev/sdb3 /mnt/home
    
    
# swapfile
    dd if=/dev/zero of=/mnt/swapfile bs=1G count=8 status=progress
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile
    
# BTRFS létrehozása és csatolása

    mkfs.vfat -F32 /dev/sda1
    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.btrfs /dev/sda3    
Btrfs subvolumes
    
    mount /dev/sda3 /mnt
    
Create subvolumes for root, home, pkg and one for snapshots

    btrfs subvolume create /mnt/@
    btrfs subvolbtrfs create /mnt/@home
    btrfs subvolume create /mnt/@var_log
    btrfs subvolume create /mnt/@snapshots
    btrfs subvolume create /mnt/@swap           # ez csak swapfile esetén kell
    
Mount them (compress=lzo)

    umount /mnt
    mount -o noatime,compress=zstd,ssd,discard=async,subvol=@root /dev/sda3 /mnt
    mkdir -p /mnt/{boot,home,var/log,.snapshots,swap}
    mount -o noatime,compress=zstd,ssd,discard=async,subvol=@home /dev/sda3 /mnt/home
    mount -o noatime,compress=zstd,ssd,discard=async,subvol=@var_log /dev/sda3 /mnt/var/log
    mount -o noatime,compress=zstd,space_cache,ssd,subvol=@snapshots /dev/sda3 /mnt/.snapshots
    mount -o subvol=@swap /dev/sda3 /mnt/swap
    
    mount /dev/sda1 /mnt/boot
    
Btrfs swapfile

    cd /mnt/swap
    truncate -s 0 ./swapfile
    chmod 600 ./swapfile
    chattr +C ./swapfile
    btrfs property set ./swapfile compression none
    
    dd if=/dev/zero of=/mnt/swap/swapfile bs=1G count=8 status=progress
    mkswap /mnt/swap/swapfile
    swapon /mnt/swap/swapfile
    
Így kell majd kinéznie az fstab-ban

    UUID=ba27f630-8bcf-45d8-a303-b2dd672d9a56	/swap     	btrfs     	subvol=@swap	0 0
    /swap/swapfile      	none      	swap      	defaults  	0 0
    
# a resume_offset-et btrfs esetén így lehet kinyerni
    Btrfs_map_pysical.c letöltése innen: https://github.com/osandov/osandov-linux/blob/master/scripts/btrfs_map_physical.c

A progromot le kell fordítani
     
    gcc -O2 -o btrfs_map_physical btrfs_map_physical.c
    
Lefuttatjuk a swapfile-n
    
    ./btrfs_map_physical /swap/swapfile
    
A PHYSICAL OFFSET eredménye kell nekünk

    FILE OFFSET  EXTENT TYPE  LOGICAL SIZE  LOGICAL OFFSET  PHYSICAL SIZE  DEVID  PHYSICAL OFFSET
    0            regular      4096          2927632384      268435456      1      4009762816 < ------ EZ kell
    4096         prealloc     268431360     2927636480      268431360      1      4009766912
    268435456    prealloc     268435456     3251634176      268435456      1      4333764608
    536870912    prealloc     268435456     3520069632      268435456      1      4602200064
    805306368    prealloc     268435456     3788505088      268435456      1      4870635520
    1073741824   prealloc     268435456     4056940544      268435456      1      5139070976
    1342177280   prealloc     268435456     4325376000      268435456      1      5407506432
    1610612736   prealloc     268435456     4593811456      268435456      1      5675941888
    
Ezután lefuttatjuk ezt

    getconf PAGESIZE
       
Majd a két számot elosztjuk

    4009762816 / 4096 = 978946
    
És végül a kapott eredményt beírjuk

    resume_offset=978946
    
    
# Kapcsolódás az internethez
    iwctl
    
device helyett pl a wlan0 kell

    device list
    station wlan0 scan
    station wlan0 get-networks
    station wlan0 connect OTTHONI_WIFI

# A alaprendszer csomagjai
    pacstrap /mnt base base-devel linux-lts linux-firmware neovim btrfs-progs git

# Rendszer konfigurálása # Fstab
    genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
    arch-chroot /mnt

# Időzóna
    ln -sf /usr/share/zoneinfo/Europe/Budapest /etc/localtime

# Magyarosítás 
/etc/locale.conf

    LANG=hu_HU.UTF-8
    LC_COLLATE=C

/etc/vconsole.conf

    KEYMAP=hu
    FONT=lat2-16

/etc/locale.gen add uncomment

    en_US.UTF-8 UTF-8
    hu_HU.UTF-8 UTF-8
   
Generate the locales by running
    
    locale-gen

# Hálózat konfigurálása
/etc/hostname

    Aporka
    
/etc/hosts

    127.0.0.1	localhost
    127.0.1.1   Galamb # manjaron így van
    ::1		localhost ip6-localhost ip6-loopback    # a localhost rész után a manjaro beállítás így néz ki
    127.0.1.1	myhostname.localdomain	myhostname
    ff02::1     ip6-allnodes        # manjaro ip6
    ff02::2     ip6-allrouters      # manjaro ip6
    
    
# Initramfs
/etc/mkinitcpio.conf

    MODULE="i915" -> MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)
    HOOKS="...resume..."
    
btrfs esetén a fsck-t törölnikell és valahogy így kell, hogy kinézzen

    HOOKS=(base udev autodetect modconf block resume btrfs filesystems keyboard)
    
initramfs generálása:
    
    mkinitcpio -P

# Rendszerbetöltő (grub)
    pacman -S grub efibootmgr grub-btrfs
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck

/etc/default/grub

    GRUB_DEFAULT=saved
    GRUB_SAVEDEFAULT=true
    GRUB_DISABLE_SUBMENU=y
    GRUB_CMDLINE_LINUX="resume=PARTUUID=5e2f720e-c62f-4e71-8c65-c98ff73c7823 resume_offset=16400 nvidia-drm.modeset=1"
   
Grub konfig generálása

    grub-mkconfig -o /boot/grub/grub.cfg

# swap partíció resume beírása
    blkid -s PARTUUID -o value /dev/sdb2 >> /etc/default/grub

# swapfile kiderítése ebből a 8257536 kell
    filefrag -v /swapfile
        ext:     logical_offset:        physical_offset: length:   expected: flags:
        0:        0..  131071:    8257536..   8388607: 131072:            
        1:   131072..  622591:    8421376..   8912895: 491520:    8388608:
        2:   622592.. 1114111:    8945664..   9437183: 491520:    8912896:
        3:  1114112.. 1605631:    9469952..   9961471: 491520:    9437184:
        4:  1605632.. 2097151:    9994240..  10485759: 491520:    9961472: last,eof

# 
/etc/default/grub

                                                                                    |
                                                                                    | ide írjuk be
                                                                                    ˇ
    GRUB_CMDLINE_LINUX="resume=PARTUUID=5e2f720e-c62f-4e71-8c65-c98ff73c7823 resume_offset=8257536 nvidia-drm.modeset=1"

# Rendszerbetöltő (systemd-boot)

EFI boot manager telepítése

    bootctl install
    
Konfigurálás
esp/loader/loader.conf

    default arch.conf
    timeout 5
    console-mode max
    editor yes

Loader hozzáadása
esp/loader/entries/arch.conf

    title Arch Linux
    linux   /vmlinuz-linux
    initrd  /intel-ucode.img
    initrd  /initramfs-linux.img
    options root=PARTUUID=... rw rootflags=subvol=@root resume=PARTUUID=...

# EFI bejegyzések módosítása
Bejegyzések lekérdezése:
    
    efibootmgr -O
    
A 4. bejegyzés törlése:

    efibootmgr -b 4 -B
    
Az alapértelmezett bejegyzés kiválasztása. Pl a 0 lesz az első, a 2-es a második, az 1-es lesz a harmadik

    efiboomgr -O -v -o 0000,0002,0001
    
    
Bejegyzés hozzáadása a efi-hez:

    efibootmgr -c -d /dev/sda -p 7 -L <LABEL> -l \EFI\<label>\grubx64.efi
    
Ez így néz ki nálam:

    efibootmgr -c -d /dev/sdb -p 7 -L systemd -l \EFI\systemd\systemd-bootx64.efi
    
# Pár csomag telepítése az alaprendszerhez
    pacman -S netctl
            dialog
            net-tools
            links
            gptfdisk
            networkmanager
            pwgen
            mc
            ntfs-3g
            intel-ucode
            git
            vi
            
Ezután ismét le kell generálni a grub.cfg-t

    grub-mkconfig -o /boot/grub/grub.cfg
    
# NetworkManager hozzáadás a rendszerindítók közé
    systemctl enable NetworkManager

# Root jelszó
    passwd

# Reboot
    exit

    swapoff -a
    umount -R /mnt

    reboot
    
    
    
##############################
# A telepítés 2. része
##############################

# Fehasználó hozzáadása
    useradd -m -g users -G wheel,video -s /bin/bash volo
    
# Csatlakozás az internethez
    nmtui

# Pacman.conf fájlba az ILoveCandy beírása, a Multilib kikommentezése
    /etc/pacman.conf
    
        Color
        #VerbosePkgLists
        ILoveCandy
        ....
        ....
        [multilib]
        Include = /etc/pacman.d/mirrorlist

# Rendszer frissítése
    pacman -Syu

# git tárolómból letölteni az arch repót
    mkdir /mnt/github
    cd /mnt/github
    git clone https://github.com/voloferenc/arch

# snapper
    umount /.snapshots
    rm -rf /.snapshots
    snapper -c root create-config /
    snapper -c home create-config /home
    btrfs subvolume delete /.snapshots
    mkdir /.snapshots
    chmod a+rx /.snapshots
    chmod 750 /.snapshots
    chown :users /.snapshots
    mount -a
    nvim /etc/snapper/configs/root -> ALLOW_USERS="volo" ALLOW_GROUPS="users" HOURLY="5" DAILY="7" WEEKLY="0" MOUNTHLY="0" YEARLY="0"
    nvim /etc/snapper/configs/home -> ALLOW_USERS="volo" ALLOW_GROUPS="users" HOURLY="5" DAILY="7" WEEKLY="0" MOUNTHLY="0" YEARLY="0"
    systemctl enable --now snapper-timeline.timer
    systemctl enable --now snapper-cleanup.timer
    pacman -U yay
    yay -S snap-pac-grub
    nvim /etc/pacman.d/hooks/50-bootbackup.hook

        [Trigger]
        Operation = Upgrade
        Operation = Install
        Operation = Remove
        Type = Path
        Target = usr/lib/modules/*/vmlinuz

        [Action]
        Depends = rsync
        Description = Backing up /boot...
        When = PostTransaction
        Exec = /usr/bin/rsync -a --delete /boot /.bootbackup


# Saját csomagok telepítése 
    pacman -S --needed $(cat /mnt/arch/g5/arch/i3plist)
    
# beállításaim átmásolása (etc, root, usr/local/bin)
    mc /mnt/arch/g5/arch/beallitas
    
a yay telepítése

    pacman -U yay-bin-10.1.0-1-x86_64.pkg.tar.xz

# makepkg szerkesztése (MAKEOPTS="-j7")
    vim /etc/makepkg.conf

# ccache !!! Már nem kell szerkeszteni !!!
    ccache -F 10000
    ccache -M 5

# A visudo szerkesztése 
    EDITOR=nvim visudo
    
fájlban törölni a kommentet a következő rész elől

    %wheel ALL=(ALL) ALL

# sysctl (swappines) 
    sysctl -p /etc/sysctl.d/99-sysctl.conf

# Felhasználó hozzáadása a vboxusers csoporthoz (virtualbox) 
    gpasswd -a volo vboxusers

# Saját rendszerindító szkirptek
    rc.d

# Zsh beállítása
    chsh -s /bin/zsh



#####################################################
# Ezt a részt már felhasználóként kell végrehajtani
#####################################################

# Git repo letöltsée
    mkdir ~/github
        
    git config --global credential.helper store
    git config --global user.name voloferenc
    git config --global user.email voloferenc@email.com
    
    git clone https://github.com/voloferenc/arch
# Beállítások átmásolása
    mc
    
# Könyvtárak létrehozása
    xdg-user-dirs-update
    
# zsh beállítása alapértelmezettként
    chsh -s /bin/zsh
    
# Készen is vagyunk fel van telepítve a rendszerünk
    reboot


##########################################################
# Egyéb beállítások amik már nem tartoznak a telepítéshez
##########################################################

# Snapshot készítése/helyreállítás btrfs subvolume-ról/ból
Snapshot

    btrfs subvolume snapshot -r / /.snapshots/@root-`date+%F-%R`
    
Helyreállítás

    mount /dev/sda3 /mnt
    btrfs subvolume delete /mnt/@root
    btrfs subvolume snapshot /mnt/@snapshots/@root-2020-10-11-20:19 /mnt/@root
    
Utána csak újra kell indítani

# Syncthing 
    systemctl enable syncthing --user //nem rendszergazdaként kell futtatni
    systemctl start syncthing --user   
    
# Git first time
    $ git config --global user.name "John Doe"
    $ git config --global user.email johndoe@example.com

# iso mount thunar-ban utána a szerkesztés -> egyéni műveletek -> Apperance Conditions -> *********.ISO;**.iso
## * .ISO;* * .iso -> other files (pipa)
    udisksctl loop-setup -f %f 

# i3 mime xdg alapértelmezett default
# alapértelmezett fájlkezelő
    xdg-mime default thunar.desktop inode/directory
# alapértelmezett szövegszerkesztő
    xdg-mime default nvim.desktop text/plain
# alapértelmezett képnézegető
    xdg-mime default ristretto.desktop image/jpeg
    xdg-mime default ristretto.desktop image/jpg
    xdg-mime default ristretto.desktop image/png

# lekérdezni az alapértelmezett fájlkezelőt pl így kell:
    xdg-mime query default inode/directory

# i3 dot files/themes
    https://github.com/TheDarkBug/DotFiles
    https://github.com/szorfein/dotfiles

    https://www.reddit.com/r/unixporn/

# hexa color
    https://www.color-hex.com
    
# Ha gond lenne az internettel, systemd resolv-ot kell megnézni

/etc/systemd/resolved.conf

    DNS=1.1.1.1 1.0.0.1
    
Majd újra kell indítani

    systemctl restart systemd-resolved
    
# Steam flatpak
    
    sudo flatpak override --filesystem=/mnt/sda/home 
    flatpak run --filesystem=/mnt/sda/home com.valvesoftware.Steam --filesystem=/mnt/sda/home/
