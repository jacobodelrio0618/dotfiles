#!/bin/bash

# 2. Update repositories
sudo apt update

# 3. Install core UI & CLI tools
sudo apt install -y \
    neovim git curl fzf ripgrep xclip wl-clipboard \
    xmonad libghc-xmonad-contrib-dev xmobar \
    polybar picom kitty rofi hsetroot \
    sioyek zathura brightnessctl xbacklight \
    build-essential cmake pkg-config python3-pip npm \
    poppler-utils ripgrep fd-find

# 4. Install Neovim "Bridges" (The stuff that makes plugins work)
# Using pipx or pip depending on Ubuntu version; 24.04 prefers pipx or venv
python3 -m pip install --user pynvim neovim-remote --break-system-packages || \
pip install --user pynvim neovim-remote

sudo npm install -g neovim tree-sitter-cli

# Install Tectonic for lightweight LaTeX rendering
if ! command -v tectonic &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://tectonic-typesetting.github.io/install-sh | sh
    # Ensure it's in a path Neovim can see
    sudo mv tectonic /usr/local/bin/
fi
