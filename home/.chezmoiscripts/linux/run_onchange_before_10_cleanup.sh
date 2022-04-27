#!/usr/bin/env bash

# some time I make change in environemnt and residula files needs to be clean
# manually. This script takes care of that part

if [ -x "$(command -v add-apt-repository)" ]; then
    # golang ppa removal
    sudo add-apt-repository --remove -y ppa:longsleep/golang-backports
fi
