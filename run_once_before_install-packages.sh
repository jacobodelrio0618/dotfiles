#!/bin/bash

# 1. Update repositories
sudo apt update

# 2. Install core UI & CLI tools (Swapped Kitty for Alacritty)
sudo apt install -y \
    git curl fzf ripgrep xclip wl-clipboard \
    xmonad libghc-xmonad-contrib-dev xmobar \
    polybar picom alacritty rofi hsetroot \
    sioyek zathura brightnessctl xbacklight \
    build-essential cmake pkg-config python3-pip npm fd-find

# 3. Install Emacs & Doom Dependencies
# PGTK is the 'Pure GTK' version, best for laptop screen scaling and Wayland
sudo snap install emacs --classic --channel=pgtk/stable

# Dependencies for Doom modules and spellchecking
sudo apt install -y libtool-bin libvterm-dev libjansson-dev \
                    hunspell hunspell-en-us

# 4. Install Doom Emacs
if [ ! -d "$HOME/.config/emacs" ]; then
    echo "Cloning Doom Emacs..."
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install --force
else
    echo "Doom Emacs already present."
fi

# 5. Ensure Doom is in PATH and sync
export PATH="$HOME/.config/emacs/bin:$PATH"
~/.config/emacs/bin/doom sync
echo "✅ Setup complete, whore."
