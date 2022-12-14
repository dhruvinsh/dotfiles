#!/usr/bin/env bash
set -euo pipefail

echo "setup node"
curl https://get.volta.sh | bash -s -- --skip-setup
VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node@lts
# update npm to latest version
npm install -g npm

echo "Some node application installation for development"
applications=(
  neovim
  prettier
  tree-sitter-cli
)
npm install -g "${applications[@]}"
