#!/bin/bash
# Install stuff that is required to install other stuff
sudo apt-get install wget curl apt-transport-https ca-certificates gnupg-agent \
    -- software-properties-common

# LLVM
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -

# Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

# NordVPN
wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
sudo dpkg -i nordvpn-release_1.0.0_all.deb

sudo apt-get update
sudo apt-get upgrade

# Install stuff 
sudo apt-get install git vim vim-gtk3 zsh tmux lxterminal net-tools \
    -- build-essential snapd i3 nitrogen pcmanfm lxappearance redshift arandr \
    -- blueman network-manager fonts-noto pavucontrol xfce4-screenshooter \
    -- gnome-calculator j4-dmenu-desktop python3 python3-dev gitk cmake \ 
    -- cmake-curses-gui libllvm-7-ocaml-dev libllvm7 llvm-7 llvm-7-dev \ 
    -- llvm-7-doc llvm-7-examples llvm-7-runtime clang-7 clang-tools-7 \
    -- clang-7-doc libclang-common-7-dev libclang-7-dev libclang1-7 \
    -- clang-format-7 python-clang-7 apt-get install libfuzzer-7-dev \
    -- lldb-7 install lld-7 libc++-7-dev libc++abi-7-dev libomp-7-dev \
    -- nmap install docker-ce docker-ce-cli containerd.io nordvpn

if ["$0" == "--laptop"]; then
    echo "Installing laptop utils"
    sudo apt-get install xserver-xorg-input-synaptics tlp
fi

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Snaps
sudo snap install telegram-desktop
sudo snap install spotify
sudo snap install code --classic
sudo snap install postman

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's:env zsh::g' | sed 's:chsh -s .*$::g')"

# nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | zsh

# pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py

# Run docker without sudo
sudo groupadd docker
sudo usermod -aG docker $USER
