#!/usr/bin/env bash

# Check for available updates (apt-based systems)
if ! command -v apt &> /dev/null; then
    echo ""
    exit 0
fi

# Count upgradable packages
UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)

if [ "$UPDATES" -gt 0 ]; then
    echo "$UPDATES"
else
    echo ""
fi
