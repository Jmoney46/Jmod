#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="URL Plugin Installer"
PLUGIN_FUNCTION="Install Plugin From URL"
PLUGIN_DESCRIPTION="Install a plugin from a direct URL"
PLUGIN_AUTHOR="StarkMist111960 Star_destroyer11"
PLUGIN_VERSION=1

PLUGINS_DIR="/mnt/stateful_partition/murkmod/plugins"

echo "=== $PLUGIN_NAME v$PLUGIN_VERSION ==="
echo "$PLUGIN_DESCRIPTION"
echo

read -rp "Enter the plugin URL (mainly for testing): " URL

if [[ -z "$URL" ]]; then
  echo "Error: No URL provided."
  exit 1
fi

if [[ ! -d "$PLUGINS_DIR" ]]; then
  echo "Error: Plugin directory does not exist: $PLUGINS_DIR"
  exit 1
fi

cd "$PLUGINS_DIR"

echo "Downloading plugin..."
if curl -fLO "$URL"; then
  echo "Plugin downloaded successfully."
else
  echo "Error: Failed to download plugin."
  exit 1
fi
