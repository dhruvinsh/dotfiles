#!/usr/bin/env bash
# vim: set expandtab ft=bash ts=2 sw=2:
#
# Per-user xterm-256color with undercurl (Smulx) and underline colour (Setulc).
#
# tmux panes run with TERM=xterm-256color (kept so ssh to hosts without
# tmux/ghostty terminfo keeps working). The stock entry has neither cap, so
# Neovim inside tmux never emits undercurl. A compiled copy in ~/.terminfo
# shadows the system entry for local programs only; remote hosts keep using
# their own. Both ncurses and Neovim search ~/.terminfo even when $TERMINFO is
# set (Ghostty on macOS sets it), so no environment changes are needed.

set -euo pipefail

if ! command -v infocmp >/dev/null 2>&1 || ! command -v tic >/dev/null 2>&1; then
  echo "terminfo: infocmp/tic not found, skipping" >&2
  exit 0
fi

src=$(mktemp)
trap 'rm -f "$src"' EXIT

# Start from the system entry, never from a previous ~/.terminfo copy.
env -u TERMINFO -u TERMINFO_DIRS HOME=/nonexistent infocmp -x xterm-256color >"$src"
printf '\t%s,\n' \
  'Smulx=\E[4:%p1%dm' \
  'Setulc=\E[58:2::%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%d%;m' \
  >>"$src"

tic -x -o "$HOME/.terminfo" "$src"

if env -u TERMINFO infocmp -x xterm-256color | grep -q 'Smulx='; then
  echo "terminfo: ~/.terminfo xterm-256color has undercurl"
else
  echo "terminfo: ~/.terminfo/xterm-256color is not being picked up" >&2
  exit 1
fi
