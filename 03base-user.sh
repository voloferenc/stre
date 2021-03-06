#!/bin/bash
# BEGIN Config
machine="legion5"
desktop="kde" # kde i3 xfce gnome
gitpath="/mnt/doksi/" # a kde beállítások .config .local .bashrc
shell="bash" # bash zsh
# END Config

mkdir .config 2> /dev/null
mkdir .local 2> /dev/null

if [ $desktop = "i3" ]
then
	cp -a $gitpath/.config ~/
	cp -a $gitpath/.local ~/
	cp -a $gitpath/.moc ~/
	cp -a $gitpath/.vim ~/
	cp -a $gitpath/.Xdefaults ~/
	cp -a $gitpath/.Xresources ~/
	cp -a $gitpath/.bashrc ~/
	cp -a $gitpath/.gtkrc-2.0 ~/
	cp -a $gitpath/.xinitrc ~/
	cp -a $gitpath/.xprofile ~/
	cp -a $gitpath/.zshrc ~/
elif [ $desktop = "xfce" ]
then
	cp -a $gitpath/.config/Bitwarden ~/.config/
	#cp -a $gitpath/.config/nvim ~/.config/
	#cp -a $gitpath/.config/ranger ~/.config/
	cp -a $gitpath/.config/mc ~/.config/
	cp -a $gitpath/.local/TelegramDesktop ~/.local/
	#cp -a $gitpath/.vim ~/

	#cp -a $gitpath/.config/rofi ~/.config
	#cp -a $gitpath/.config/zathura ~/.config

	cp -a $gitpath/.Xdefaults ~/
	cp -a $gitpath/.Xresources ~/
	cp -a $gitpath/.bashrc ~/
	cp -a $gitpath/.gtkrc-2.0 ~/
	cp -a $gitpath/.xinitrc ~/
	cp -a $gitpath/.xprofile ~/
	#cp -a $gitpath/.zshrc ~/

else
	cp -a $gitpath/archBeallitas.zip ~/
	unzip archBeallitas.zip
	cd archBeallitas
	cp -a .config ~/
	cp -a .local ~/
	cp -a .bashrc ~/
	# cp -a $gitpath/.xinitrc ~/
	# cp -a $gitpath/.xprofile ~/
	
fi



xdg-user-dirs-update

if [ $shell = "zsh" ]
then
	chsh -s /bin/zsh
fi

if [ `pacman -Qet syncthing | awk '{print $1}'` = 'syncthing' ]
then
	systemctl enable syncthing --user
	systemctl start syncthing --user
fi

/bin/echo -e "\e[1;32mKész! Másold át a KDE beálltásaidat az adat partíciórol.[0m"
