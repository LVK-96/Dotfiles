sudo apt-get update
sudo apt-get upgrade

sudo apt-get install git vim vim-gtk3 zsh tmux curl lxterminal net-tools \
    -- build-essential snapd i3 nitrogen pcmanfm lxappearance redshift arandr

sudo snap install telegram-desktop
sudo snap install spotify
sudo snap install code --classic

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
# NordVPN
wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn-release_1.0.0_all.deb
sudo dpkg -i nordvpn-release_1.0.0_all.deb
sudo apt-get update 
sudo apt-get install nordvpn

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
