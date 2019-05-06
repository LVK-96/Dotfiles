# Change to home directory
cd ~

sudo apt-get update
sudo apt-get upgrade

# Install programs
sudo apt-get install build-essential autoconf automake libtool curl unzip python3 python3-dev scons git vim zsh tmux libprotobuf-dev python-protobuf protobuf-compiler libgoogle-perftools-dev

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
