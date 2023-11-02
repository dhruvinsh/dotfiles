#!/usr/bin/env bash
# vim: set expandtab ft=bash ts=4 tw=4:
set -euo pipefail

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

cargo_packages=(
    diffr
)

[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
cargo install "${cargo_packages[@]}"

# install ripgrep on linux machine
TARGET=/tmp/ripgrep
git clone https://github.com/BurntSushi/ripgrep $TARGET
cd $TARGET
cargo install --features 'pcre2' --path .
sudo cp $TARGET/target/release/rg /usr/bin/rg
rm -rf $TARGET
