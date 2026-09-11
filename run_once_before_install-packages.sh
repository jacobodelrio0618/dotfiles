#!/bin/bash

set -e

# 1. Update repositories
sudo apt update

# 2. Install core UI & CLI tools
sudo apt install -y \
  git curl fzf ripgrep xclip wl-clipboard \
  xmonad libghc-xmonad-contrib-dev xmobar \
  polybar picom alacritty kitty rofi hsetroot \
  sioyek zathura brightnessctl xbacklight \
  build-essential cmake pkg-config python3-pip npm fd-find \
  golang-go

# 3. Install music stack
sudo apt install -y \
  mopidy \
  mpc \
  ncmpcpp \
  playerctl \
  netcat-openbsd \
  xdotool \
  jq

# Mopidy extensions not provided by the Ubuntu packages.
python3 -m pip install --user \
  Mopidy-MPD \
  mopidy-tidal \
  tidalapi

# Install sptlrx for synced lyrics.
go install github.com/raitonoberu/sptlrx@v1.3.1

echo "Setup complete, whore"
