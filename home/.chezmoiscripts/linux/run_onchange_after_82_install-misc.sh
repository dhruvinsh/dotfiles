#!/usr/bin/env bash
set -euo pipefail

echo "Update font cache"
fc-cache -f -v

echo "Setup zoxide"
ZOXIDE=https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
curl -sS $ZOXIDE | bash
