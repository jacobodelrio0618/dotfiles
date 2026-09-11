#!/usr/bin/env bash

# Hide the text cursor and restore it automatically when exiting (Ctrl+C or script kill)
tput civis 2>/dev/null || printf '\e[?25l'
trap 'tput cnorm 2>/dev/null || printf "\e[?25h"; exit' EXIT INT TERM

# Resize window horizontally upon launch
kitten @ resize-window --axis horizontal --increment 30 2>/dev/null &

CACHE_DIR="$HOME/.cache/ncmpcpp_art"
mkdir -p "$CACHE_DIR"

LAST_URI=""
LAST_COLS=0
LAST_LINES=0

# Safely fetch terminal character grid size
get_grid() {
  read -r LINES COLUMNS < <(stty size 2>/dev/null || echo "24 80")
}

draw_art() {
  local img="$1"
  clear

  # Minimal padding: 1 cell top/bottom, 2 cells left/right
  local pad_x=2
  local pad_y=1

  local avail_w=$((COLUMNS - (pad_x * 2)))
  local avail_h=$((LINES - (pad_y * 2)))

  # Use full available width & height, letting Kitty handle 1:1 scaling
  [ "$avail_w" -lt 4 ] && avail_w=4
  [ "$avail_h" -lt 2 ] && avail_h=2

  kitten icat --clear
  kitten icat --align center --place "${avail_w}x${avail_h}@${pad_x}x${pad_y}" --scale-up "$img"
}

while true; do
  get_grid
  URI=$(mpc -f "%file%" current 2>/dev/null)

  # Redraw if track changes OR terminal grid is resized
  if [ -n "$URI" ] && { [ "$URI" != "$LAST_URI" ] || [ "$COLUMNS" -ne "$LAST_COLS" ] || [ "$LINES" -ne "$LAST_LINES" ]; }; then

    if [ "$URI" != "$LAST_URI" ]; then
      LAST_URI="$URI"
      IMAGE_URL=$(curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"core.library.get_images\", \"params\": {\"uris\": [\"$URI\"]}}" \
        http://localhost:6680/mopidy/rpc | jq -r '.result[][0].uri // empty')

      if [ -n "$IMAGE_URL" ]; then
        curl -s "$IMAGE_URL" -o "$CACHE_DIR/cover.jpg"
      else
        rm -f "$CACHE_DIR/cover.jpg"
      fi
    fi

    LAST_COLS="$COLUMNS"
    LAST_LINES="$LINES"

    if [ -f "$CACHE_DIR/cover.jpg" ]; then
      draw_art "$CACHE_DIR/cover.jpg"
    else
      kitten icat --clear
      clear
      echo "No album art available"
    fi
  fi
  sleep 1
done
