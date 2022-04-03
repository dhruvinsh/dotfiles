#!/usr/bin/env bash
set -euo pipefail

echo "setup node"
NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
# update npm to latest version
npm install -g npm

echo "Some LSP installation for development"
server=(
    pyright
    eslint
    typescript-language-server
    typescript
)
npm install -g pyright
