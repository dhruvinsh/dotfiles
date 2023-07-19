#!/usr/bin/env bash
# vim: set expandtab ft=bash ts=4 tw=4:
set -euo pipefail

sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt update
sudo apt install -y golang-go
