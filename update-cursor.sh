#!/bin/bash

export $(dbus-launch)

set -e

INSTALL_DIR="/opt/cursor"
APPIMAGE_PATH="$INSTALL_DIR/cursor.AppImage"
VERSION_PATH="$INSTALL_DIR/version.txt"
UPDATE_JSON_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"

mkdir -p "$INSTALL_DIR"

# Get current version
CURRENT_VERSION=""
[[ -f "$VERSION_PATH" ]] && CURRENT_VERSION=$(<"$VERSION_PATH")

# Get metadata
JSON=$(curl -s "$UPDATE_JSON_URL")
LATEST_VERSION=$(echo "$JSON" | jq -r '.version')
DOWNLOAD_URL=$(echo "$JSON" | jq -r '.downloadUrl')

# Only show UI if there is an update
if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  exit 0  # No update needed, so we exit without showing the UI
fi

# Show initial checking UI
zenity --info --title="Cursor Updater" --text="A new update (v$LATEST_VERSION) is available. Downloading now..."

# Show progress while downloading
(
  echo "10"
  echo "# Downloading Cursor v$LATEST_VERSION..."
  # Download the file with progress updates
  wget -q --show-progress -O "$APPIMAGE_PATH" "$DOWNLOAD_URL" 2>&1 | while IFS= read -r line; do
    # Parse the progress percentage
    if [[ "$line" =~ ([0-9]+)% ]]; then
      PERCENT="${BASH_REMATCH[1]}"
      echo "$PERCENT"
    fi
  done
  echo "70"
  echo "# Making AppImage executable..."
  chmod +x "$APPIMAGE_PATH"
  echo "90"
  echo "# Finalizing update..."
  echo "$LATEST_VERSION" > "$VERSION_PATH"
  echo "100"
  echo "# Cursor updated to v$LATEST_VERSION."
) | zenity --progress \
  --title="Updating Cursor" \
  --text="Starting update..." \
  --percentage=0 \
  --auto-close \
  --cancel-label="Cancel Update" \
  --width=400 --height=100

# Final notification
zenity --info --title="Cursor Updater" --text="Cursor updated to version $LATEST_VERSION successfully!"
