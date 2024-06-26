#!/usr/bin/env bash
# vim: set expandtab ts=4 sw=4 ft=sh:
set -euo pipefail

# if there is change in python version we need to install the package,
# HACK: just call the python variable to force run this script
echo "Installed python version is: {{ .pythonVersion }}"

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
    codespell
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
    uv
)

# setup poetry env via pipx
for pkg in "${packages[@]}"
do
    echo "*** Setting up $pkg ***"
    pipx install "$pkg"
done

pipx inject poetry poetry-plugin-export
