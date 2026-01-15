#!/bin/bash
set -e

# Configuration
DOTFILES_DIR="$HOME/Dotfiles"
REPO_URL="https://github.com/LVK-96/Dotfiles.git"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Starting Portable Environment Setup (via Pixi)...${NC}"

# 1. Install Pixi
if ! command -v pixi &> /dev/null; then
    echo -e "${BLUE}Installing Pixi...${NC}"
    curl -fsSL https://pixi.sh/install.sh | bash
    export PATH="$HOME/.pixi/bin:$PATH"
else
    echo "Pixi already installed."
fi

# 2. Install Tools via Pixi Global
# This installs binaries to ~/.pixi/bin which is in PATH
TOOLS="nvim fzf ripgrep stow git tmux nodejs"

echo -e "${BLUE}Installing tools: $TOOLS${NC}"
pixi global install $TOOLS

# 2.1 Install Opencode via NPM (Pixi provides node/npm)
if ! command -v opencode &> /dev/null; then
    echo -e "${BLUE}Installing OpenCode...${NC}"
    curl -fsSL https://opencode.ai/install | bash
fi

# 3. Clone Dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${BLUE}Cloning Dotfiles...${NC}"
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles already cloned."
fi

# 4. Link Configs (Stow)
cd "$DOTFILES_DIR"
echo -e "${BLUE}Linking configurations...${NC}"

# Link packages
PACKAGES="bash nvim alacritty vim git tmux rofi opencode"

for pkg in $PACKAGES; do
    if [ -d "$pkg" ]; then
        echo "Stowing $pkg..."
        stow -d "$DOTFILES_DIR" -t "$HOME" --adopt "$pkg" || echo "Warning: Stow failed for $pkg"
        git restore . &>/dev/null || true
    fi
done

echo -e "${GREEN}Setup Complete!${NC}"
echo "Debug: Checking stow results..."
ls -l ~/.bashrc | grep "\->" || echo "Warning: .bashrc is not a symlink"

echo "Environment setup!"
