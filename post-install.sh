# Add repositories
sudo add-apt-repository universe
sudo add-apt-repository ppa:papirus/papirus

# Update and upgrade
sudo apt-get update
sudo apt-get upgrade

# Install packages
sudo apt-get install build-essential tilix chromium-browser vim zsh cmake libreoffice gnome-tweak-tool gnome-session htop python python3 fonts-powerline autoconf automake libgtk-3-dev papirus-icon-theme neofetch

sudo snap install telegram-desktop
sudo snap install spotify

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

# Load gnome config
dconf load /org/gnome/ < gnome.txt

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) | sed 's:env zsh -l::g' | sed 's:chsh -s .*$::g')"

# Replace default .zshrc with my config
sudo cat .zshrc > ~/.zshrc
source ~/.zshrc

# zsh syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

