#!/usr/bin/env bash
set -euo pipefail

# to create a bootsplash tar.gz: 
# yt-dlp https://www.youtube.com/watch?v=Fnz9ljn1cwE -f mp4 
# ffmpeg -i <video>.mp4 -vf "fps=25" bootsplash/boot_splash_frame%03d.png 
# tar -czvf bootsplash.tar.gz bootsplash/

PLUGIN_NAME="Bootsplasher"
PLUGIN_FUNCTION="Set custom boot splash"
PLUGIN_DESCRIPTION="Set a custom ChromeOS boot splash"
PLUGIN_AUTHOR="rainestorme"
PLUGIN_VERSION=1

ASSETS_DIR="/usr/share/chromeos-assets/images_100_percent"
DOWNLOADS="/home/chronos/user/Downloads"
TMP_DIR="/tmp"
SSH_OPTS="-t -p 1337 -i /rootkey -oStrictHostKeyChecking=no"

doas() {
  ssh $SSH_OPTS root@127.0.0.1 "$@"
}

clear_existing() {
  doas "rm -f $ASSETS_DIR/boot_splash_frame*.png"
}

copy_static() {
  echo "Installing static bootsplash..."
  clear_existing
  doas "cp $TMP_DIR/bootsplash.png $ASSETS_DIR/boot_splash_frame00.png"
  rm -f "$TMP_DIR/bootsplash.png"
  echo "Done!"
}

copy_animated() {
  echo "Installing animated bootsplash..."
  clear_existing
  doas "cp $TMP_DIR/bootsplash/*.png $ASSETS_DIR/"
  rm -rf "$TMP_DIR/bootsplash"
  echo "Done!"
}

get_asset() {
  curl -sf "https://api.github.com/repos/rainestorme/murkmod/contents/$1" \
    | jq -r ".content" \
    | base64 -d
}

install_asset() {
  local asset="$1"
  local target="$2"
  local tmp

  tmp="$(mktemp)"
  if ! get_asset "$asset" >"$tmp" || ! grep -q '[^[:space:]]' "$tmp"; then
    echo "Failed to install asset: $asset"
    rm -f "$tmp"
    exit 1
  fi

  cat "$tmp" >"$target"
  rm -f "$tmp"
}

set_custom_static() {
  read -rp "Enter PNG filename from Downloads > " file
  local src="$DOWNLOADS/$file"

  [[ -f "$src" ]] || { echo "File not found."; exit 1; }

  cp "$src" "$TMP_DIR/bootsplash.png"
  copy_static
}

set_custom_animated() {
  read -rp "Enter folder name from Downloads > " folder
  local src="$DOWNLOADS/$folder"

  [[ -d "$src" ]] || { echo "Folder not found."; exit 1; }

  cp -r "$src" "$TMP_DIR/bootsplash"
  copy_animated
}

restore_murkmod() {
  echo "Restoring MurkMod default bootsplash..."
  install_asset "chromeos-bootsplash-v2.png" "$TMP_DIR/bootsplash.png"
  copy_static
}

get_bootsplash() {
  local name="$1"
  local out="$2"

  echo "Downloading $name..."
  curl -fsL "https://raw.githubusercontent.com/rainestorme/bootsplashes/main/$name" -o "$out"
}

choose_bootsplash() {
  echo "Select a bootsplash:"
  echo " 1. Pip-boy"
  echo " 2. Valve Intro"
  echo " 3. PS2 Startup"
  echo " 4. Xbox Startup"
  echo " 5. GameCube Startup"
  echo " 6. Apple Logo"
  read -rp "> (1-6): " choice

  case "$choice" in
    1) get_bootsplash "pipboy.tar.gz" "$TMP_DIR/bootsplash.tar.gz" ;;
    2) get_bootsplash "valve.tar.gz" "$TMP_DIR/bootsplash.tar.gz" ;;
    3) get_bootsplash "ps2.tar.gz" "$TMP_DIR/bootsplash.tar.gz" ;;
    4) get_bootsplash "xbox.tar.gz" "$TMP_DIR/bootsplash.tar.gz" ;;
    5) get_bootsplash "gamecube.tar.gz" "$TMP_DIR/bootsplash.tar.gz" ;;
    6) get_bootsplash "apple.tar.gz" "$TMP_DIR/bootsplash.tar.gz" ;;
    *) echo "Invalid option."; exit 1 ;;
  esac

  tar -xzf "$TMP_DIR/bootsplash.tar.gz" -C "$TMP_DIR"
  copy_animated
}

echo "Make sure static bootsplashes are PNGs."
echo "Animated bootsplashes must be in a folder named 'bootsplash'."
echo
echo "Select an option:"
echo " 1. Set custom static bootsplash"
echo " 2. Set custom animated bootsplash"
echo " 3. Restore MurkMod default"
echo " 4. Choose pre-made bootsplash"
read -rp "> (1-4): " choice

case "$choice" in
  1) set_custom_static ;;
  2) set_custom_animated ;;
  3) restore_murkmod ;;
  4) choose_bootsplash ;;
  *) echo "Invalid option." ;;
esac

sync
exit 0
