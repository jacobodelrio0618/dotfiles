#!/usr/bin/env bash

# Launch cover art script in a left panel, then launch ncmpcpp on the right.
kitty @ launch --location=vsplit --cwd=current ~/.config/ncmpcpp/show_art.sh
ncmpcpp
