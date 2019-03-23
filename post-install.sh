# Add repositories
sudo add-apt-repository universe
sudo add-apt-repository ppa:papirus/papirus

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade

# Install packages
sudo apt-get install curl tilix build-essential vim zsh cmake libreoffice gnome-tweak-tool gnome-session htop python python3 fonts-powerline autoconf automake libgtk-3-dev papirus-icon-theme neofetch

# Snaps for telegram, spotify and vscode
sudo snap install telegram-desktop
sudo snap install spotify
sudo snap install vscode --classic

# Install chrome
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Copy my vimrc
sudo cp .vimrc ~

# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python get-pip.py

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's:env zsh -l::g' | sed 's:chsh -s .*$::g')"

# Make zsh default shell
chsh -s $(which zsh)
sudo chsh -s $(which zsh)

# Replace default .zshrc with my config
sudo cat .zshrc > ~/.zshrc
