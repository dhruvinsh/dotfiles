#!/usr/bin/env bash
# Polybar custom/script: number of upgradable apt packages (empty when none,
# which hides the module).

command -v apt >/dev/null 2>&1 || exit 0

count=$(apt list --upgradable 2>/dev/null | grep -c '\[upgradable')

if [ "$count" -gt 0 ]; then
  echo "$count"
fi
