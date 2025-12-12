#!/bin/bash

# Get list of all workspaces (1-9 in your config)
for i in {1..9}; do
    # Check if workspace has any windows
    window_count=$(i3-msg -t get_workspaces | jq ".[] | select(.num==$i) | .num" 2>/dev/null)

    # If workspace doesn't exist or exists but is empty, use it
    if [ -z "$window_count" ]; then
        i3-msg workspace number "$i"
        exit 0
    fi
done
