#!/bin/bash
sudo pacman -Syu git curl wget ca-certificates gnupg xterm zsh nmap tmux \
		 lxterminal htop neofetch xorg-server gvim flatpak code \
		 lxappearance i3-wm i3blocks i3lock i3status nitrogen pcmanfm arandr \
         networkmanager noto-fonts pavucontrol xfce4-screenshooter \
         gnome-calculator cmake firefox tk irssi chromium xorg-xinit python \
         dmenu network-manager-applet pulseaudio clang lld lldb gcc docker \
         telegram-desktop llvm openmp redshift docker-compose mutt openssh vlc \
         openvpn networkmanager-openvpn pcmanfm dialog wpa_supplicant blueman

# Flatpaks
flatpak install flathub com.spotify.Client
flatpak install flathub com.getpostman.Postman

# Heroku AUR
git clone https://aur.archlinux.org/heroku-cli.git
cd heroku-cli
makepkg -si
cd .. 
sudo rm -rf heroku-cli

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Oh My Zsh
curl -Lo install.sh https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh
sh install.sh --unattended

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | zsh

# pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py

# Run docker without sudo
sudo usermod -aG docker $USER

# Change default shell to zsh
echo "Change default shell to zsh"
chsh -s /usr/bin/zsh

# Make desktop entries work
sudo cp zprofile /etc/zsh/

# Copy config files
cp .vimrc ~
cp .xinitrc ~
cp .zshrc ~
cp .tmux.conf ~
cp .Xresources ~

if [ ! -d "~/.config" ]; then
    mkdir ~/.config
fi
cp -r .config/* ~/.config/

# I prob already did this to make networking work
# Also don't forget to edit config file: 
# https://wiki.archlinux.org/index.php/Systemd-networkd#Basic_usage
sudo systemctl enable systemd-networkd.service
sudo systemctl enable systemd-resolved.service
sudo systemctl enable NetworkManager.service
