#!/bin/bash
set -e

# Usage: ./bootstrap.sh [INSTALL_PREFIX]
# INSTALL_PREFIX defaults to $HOME

# Configuration - ensure absolute path
INSTALL_PREFIX="$(cd "${1:-$HOME}" 2>/dev/null && pwd || echo "${1:-$HOME}")"
if [[ "$INSTALL_PREFIX" != /* ]]; then
    INSTALL_PREFIX="$(pwd)/$INSTALL_PREFIX"
    mkdir -p "$INSTALL_PREFIX"
    INSTALL_PREFIX="$(cd "$INSTALL_PREFIX" && pwd)"
fi
DOTFILES_DIR="$INSTALL_PREFIX/Dotfiles"
PIXI_HOME="$INSTALL_PREFIX/.pixi"
LOCAL_DIR="$INSTALL_PREFIX/.local"
CONFIG_DIR="$INSTALL_PREFIX/.config"
REPO_URL="https://github.com/LVK-96/Dotfiles.git"

# Export PIXI_HOME so pixi installs to correct location
export PIXI_HOME

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Starting Portable Environment Setup (via Pixi)...${NC}"
echo -e "${BLUE}Install prefix: $INSTALL_PREFIX${NC}"

# 1. Install Pixi
if ! command -v pixi &> /dev/null; then
    echo -e "${BLUE}Installing Pixi to $PIXI_HOME...${NC}"
    curl -fsSL https://pixi.sh/install.sh | PIXI_HOME="$PIXI_HOME" bash
    export PATH="$PIXI_HOME/bin:$PATH"
else
    echo "Pixi already installed."
fi

# 2. Install Tools via Pixi Global
TOOLS="nvim fzf ripgrep stow git tmux nodejs"

echo -e "${BLUE}Installing tools: $TOOLS${NC}"
pixi global install $TOOLS

# 2.1 Install Opencode
if ! command -v opencode &> /dev/null; then
    echo -e "${BLUE}Installing OpenCode...${NC}"
    curl -fsSL https://opencode.ai/install | bash
fi

# 3. Clone Dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${BLUE}Cloning Dotfiles to $DOTFILES_DIR...${NC}"
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    echo "Dotfiles already cloned."
fi

# 4. Link Configs (Stow)
cd "$DOTFILES_DIR"
echo -e "${BLUE}Linking configurations to $INSTALL_PREFIX...${NC}"

# Link packages
PACKAGES="bash nvim alacritty vim git tmux rofi opencode"

for pkg in $PACKAGES; do
    if [ -d "$pkg" ]; then
        echo "Stowing $pkg..."
        stow -d "$DOTFILES_DIR" -t "$INSTALL_PREFIX" --adopt "$pkg" || echo "Warning: Stow failed for $pkg"
        git restore . &>/dev/null || true
    fi
done

echo -e "${GREEN}Setup Complete!${NC}"
echo "Debug: Checking stow results..."
ls -l "$INSTALL_PREFIX/.bashrc" | grep "\->" || echo "Warning: .bashrc is not a symlink"

echo ""
echo "Environment setup at: $INSTALL_PREFIX"
echo ""
echo "Add to your shell rc if using non-default prefix:"
echo "  export PIXI_HOME=\"$PIXI_HOME\""
echo "  export PATH=\"$PIXI_HOME/bin:\$PATH\""
