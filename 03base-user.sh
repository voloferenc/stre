#!/bin/bash
# BEGIN Config
machine="legion5"
desktop="kde" # kde i3 xfce gnome
gitpath="~/github/stre/arch/$machine/arch/beallitas/home"
shell="zsh" # bash zsh
# END Config

/mnt/sda/home/./git.sh

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
	cp -a $gitpath/.config/nvim ~/.config/
	cp -a $gitpath/.config/ranger ~/.config/
	cp -a $gitpath/.config/mc ~/.config/
	cp -a $gitpath/.local/TelegramDesktop ~/.local/
	cp -a $gitpath/.vim ~/

	cp -a $gitpath/.config/rofi ~/.config
	cp -a $gitpath/.config/zathura ~/.config

	cp -a $gitpath/.Xdefaults ~/
	cp -a $gitpath/.Xresources ~/
	cp -a $gitpath/.bashrc ~/
	cp -a $gitpath/.gtkrc-2.0 ~/
	cp -a $gitpath/.xinitrc ~/
	cp -a $gitpath/.xprofile ~/
	cp -a $gitpath/.zshrc ~/

else
	cp -a $gitpath/.config/Bitwarden ~/.config/
	cp -a $gitpath/.config/nvim ~/.config/
	cp -a $gitpath/.config/ranger ~/.config/
	cp -a $gitpath/.config/mc ~/.config/
	cp -a $gitpath/.local/TelegramDesktop ~/.local/
	cp -a $gitpath/.local/TelegramDesktop ~/.local/
	cp -a $gitpath/.vim ~/
	cp -a $gitpath/.Xresources ~/
	cp -a $gitpath/.bashrc ~/
	# cp -a $gitpath/.xinitrc ~/
	# cp -a $gitpath/.xprofile ~/
	cp -a $gitpath/.zshrc ~/

fi



xdg-user-dirs-update

if [ $shell = "zsh" ]
then
	chsh -s /bin/zsh
fi

/bin/echo -e "\e[1;32mÚjraindítás 5..4..3..2..1..\e[0m"
sleep 5
reboot
