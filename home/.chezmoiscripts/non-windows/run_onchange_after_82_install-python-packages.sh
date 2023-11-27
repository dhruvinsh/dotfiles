#!/usr/bin/env bash
# vim: set expandtab ts=4 sw=4 ft=sh:
set -euo pipefail

PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Some workflow based setup since pip is available
echo "*** Installing python packages ***"
pip install -U pip pipx pynvim

# just perform the cleanup
pipx uninstall-all

# create some independent envs with packages 
packages=(
    black
    flake8
    httpie
    isort
    jupyterlab
    mypy
    pipenv
    poetry
    pre-commit
    pylint
    ruff
)

# setup poetry env via pipx
for pkg in "${packages[@]}"
do
    echo "*** Setting up $pkg ***"
    pipx install "$pkg"
done
