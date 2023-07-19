#!/usr/bin/env bash
set -euo pipefail

echo "Update font cache"
fc-cache -f -v
