#!/usr/bin/env bash
# vim: set expandtab ft=bash ts=2 sw=2:
#
# gh rewrites ~/.config/gh/config.yml itself (aliases, hosts, prompts), so
# chezmoi doesn't own the file; it sets the two values that matter here.
#   git_protocol ssh   clone/push over ssh (matches the url.insteadOf in git)
#   telemetry off      on by default (see `gh config --help`)
# Re-runs when this script changes.

set -uo pipefail

gh=$(command -v gh || "$HOME"/.local/bin/mise which gh 2>/dev/null || true)
if [[ -z $gh ]]; then
  echo "gh: not installed, skipping config" >&2
  exit 0
fi

"$gh" config set git_protocol ssh &&
  "$gh" config set telemetry disabled &&
  echo "gh: git_protocol=ssh, telemetry=disabled"
exit 0
