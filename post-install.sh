# Install curl and git
sudo apt-get install curl 

# Add keyrings and sources
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo add-apt-repository universe
sudo add-apt-repository ppa:linrunner/tlp
sudo add-apt-repository ppa:papirus/papirus

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade

# Install packages
sudo apt-get install build-essential chromium-browser vim zsh cmake libreoffice gnome-tweak-tool htop tlp tlp-rdw python python3 fonts-powerline autoconf automake libgtk-3-dev papirus-icon-theme neofetch code spotify qemu-kvm qemu virt-manager virt-viewer libvirt-bin
# Install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python get-pip.py

# Make zsh default shell
chsh -s $(which zsh)
sudo chsh -s $(which zsh)

# solArc theme
git clone https://github.com/apheleia/solarc-theme --depth 1 && cd solarc-theme
./autogen.sh --prefix=/usr
sudo make install

# load gnome config 
dconf load /org/gnome/ < gnome.txt

# ubuntu login screen colors 
cat ubuntu.css > /usr/share/gnome-shell/theme/ubuntu.css 

# Install oh my zsh 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh syntax highlighting 
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Replace default .zshrc with my config
cat .zshrc > ~/.zshrc
source ~/.zshrc


