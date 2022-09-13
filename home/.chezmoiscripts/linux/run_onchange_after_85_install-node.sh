#!/usr/bin/env bash
set -euo pipefail

echo "setup node"
NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR"/nvm.sh
nvm install --lts
# update npm to latest version
npm install -g npm

echo "Some node application installation for development"
applications=(
  eslint
  prettier
  pyright
  tldr
  tree-sitter-cli
  typescript
  typescript-language-server
  yarn
)
npm install -g "${applications[@]}"
