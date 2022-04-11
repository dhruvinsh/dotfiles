#!/usr/bin/env bash
set -euo pipefail

echo "update font cache"
fc-cache -f -v

echo "setup autojump"
AUTOJUMP=https://github.com/wting/autojump.git
AUTOJUMP_DIR=/tmp/autojump
if [ ! -d $AUTOJUMP_DIR ]; then
    git clone $AUTOJUMP $AUTOJUMP_DIR
fi
cd $AUTOJUMP_DIR
./install.py
