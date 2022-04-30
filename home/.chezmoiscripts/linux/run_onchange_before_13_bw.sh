#!/usr/bin/env bash
set -euo pipefail

# bitwarden cli setup
echo "Setting up bitwarden cli"
URL="https://vault.bitwarden.com/download/?app=cli&platform=linux"
LOCALBIN=$HOME/.local/bin
wget "$URL" -O /tmp/bw.zip

# just incase if we don't have .local/bin directory
mkdir -p "$LOCALBIN"
unzip -o /tmp/bw.zip -d "$LOCALBIN"
chmod +x "$LOCALBIN"/bw
