# Change to home directory
cd ~

sudo apt-get update
sudo apt-get upgrade

# Install programs
sudo apt-get install build-essential autoconf automake libtool curl unzip python3 python3-dev scons git vim zsh tmux

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install protobuff https://github.com/protocolbuffers/protobuf
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh
./configure
make
make check
sudo make install
sudo ldconfig # refresh shared library cache.
