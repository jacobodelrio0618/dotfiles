#!/bin/bash

# 1. Enable 32-bit architecture (Required for Wine)
sudo dpkg --add-architecture i386

# 2. Update repositories
sudo apt update

# 3. Install core UI & CLI tools
sudo apt install -y \
    neovim git curl fzf ripgrep xclip wl-clipboard \
    xmonad libghc-xmonad-contrib-dev xmobar \
    polybar picom alacritty rofi hsetroot \
    sioyek zathura brightnessctl xbacklight \
    build-essential cmake pkg-config python3-pip npm

# 4. Install Neovim "Bridges" (The stuff that makes plugins work)
# Using pipx or pip depending on Ubuntu version; 24.04 prefers pipx or venv
python3 -m pip install --user pynvim neovim-remote --break-system-packages || \
pip install --user pynvim neovim-remote

sudo npm install -g neovim tree-sitter-cli
