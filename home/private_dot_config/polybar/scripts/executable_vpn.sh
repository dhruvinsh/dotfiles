#!/usr/bin/env bash

# Check for autossh processes (your VPN tunnels)
JUMPSERVER=$(pgrep -f "autossh.*jumpserver-labnet" > /dev/null && echo "JS")
COLLECTOR=$(pgrep -f "autossh.*exe-collector" > /dev/null && echo "EC")

if [ -n "$JUMPSERVER" ] || [ -n "$COLLECTOR" ]; then
    echo "$JUMPSERVER $COLLECTOR"
else
    echo ""
fi
