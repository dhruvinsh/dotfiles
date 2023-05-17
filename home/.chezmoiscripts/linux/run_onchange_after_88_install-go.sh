#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository -y ppa:longsleep/golang-backports
sudo apt update
sudo apt install -y golang-go
