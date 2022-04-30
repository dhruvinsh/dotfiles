#!/usr/bin/env bash
set -euo pipefail

# create tpm directory
# chezmoi does not create parent directories
# https://github.com/twpayne/chezmoi/issues/1205
mkdir -p "$HOME"/.tmux/plugins/tpm
