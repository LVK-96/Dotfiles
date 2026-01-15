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
TOOLS="fish nvim fzf ripgrep stow git tmux nodejs"

echo -e "${BLUE}Installing tools: $TOOLS${NC}"
pixi global install $TOOLS

# 2.1 Install Opencode via NPM (Pixi provides node/npm)
if ! command -v opencode &> /dev/null; then
    echo -e "${BLUE}Installing OpenCode...${NC}"
    npm install -g opencode-ai
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
# Note: we stow 'bash' too, which includes the auto-switch to fish
PACKAGES="bash nvim fish alacritty vim git tmux rofi opencode"

for pkg in $PACKAGES; do
    if [ -d "$pkg" ]; then
        echo "Stowing $pkg..."
        stow -d "$DOTFILES_DIR" -t "$HOME" --adopt "$pkg" || echo "Warning: Stow failed for $pkg"
        git restore . &>/dev/null || true
    fi
done

# 4.1 Install Fisher plugins (Fish)
if [ -f "$HOME/.config/fish/fish_plugins" ]; then
    echo -e "${BLUE}Installing Fisher plugins...${NC}"
    # Use 'fish -c' to run fisher install in a fish shell
    # We install fisher itself first if needed (though bootstrap usually handles only the plugins via fisher)
    # But since we ignored fisher.fish, we need to bootstrap fisher first.
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update"
fi

# 4.2 Install Neovim Plugins (Lazy.nvim)
echo -e "${BLUE}Installing Neovim plugins (Lazy)...${NC}"
# Run headless Lazy sync. 
# We ignore errors because sometimes first-run treesitter compilations output stuff to stderr.
nvim --headless "+Lazy! sync" +qa || echo "Neovim plugin install finished with some warnings (normal for first run)."

echo -e "${GREEN}Setup Complete!${NC}"
echo "Debug: Checking stow results..."
ls -l ~/.bashrc | grep "\->" || echo "Warning: .bashrc is not a symlink"
ls -l ~/.config/fish/functions/fish_prompt.fish || echo "Warning: fish_prompt.fish missing"

echo "Restart your terminal. Pixi has installed Fish shell."
