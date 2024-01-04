#!/usr/bin/env bash
# vim: set expandtab ft=bash ts=4 tw=4:
set -euo pipefail

sudo apt install -y libevent-dev bison flex
git clone https://github.com/tmux/tmux.git /tmp/tmux
cd /tmp/tmux
sh autogen.sh
./configure
make
cp tmux ~/.local/bin/tmux
cd ~
rm -rf /tmp/tmux
