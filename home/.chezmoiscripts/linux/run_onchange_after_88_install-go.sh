#!/usr/bin/env bash
set -euo pipefail

sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install golang-go
